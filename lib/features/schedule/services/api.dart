import 'dart:async';
import 'dart:io' show HttpClient;
import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/logger/session_logger.dart';
import '../../cache/provider/cache_provider.dart';
import '../models/request_type.dart';
import '../models/schedule_model.dart';
import '../models/schedule_response.dart';

typedef Params = ({
  DateTime startDate,
  DateTime endDate,
  ScheduleModel scheduleModel,
  bool forceUpdate,
});

class ApiService {
  static const String name = "ApiService";
  static const int defaultPrefetchDays = 30;

  final int _prefetchDays;
  final CacheProvider? cacheProvider;

  final Dio _dio;

  final _querySubject = PublishSubject<_SearchRequest>();

  ApiService({
    this.cacheProvider,
    Dio? dio,
    int prefetchDays = defaultPrefetchDays,
  })  : _prefetchDays = prefetchDays,
        _dio = dio ?? Dio() {
    if (dio == null) {
      _configureDio();
    }

    _initPipeline();
  }

  final String _baseUrl = 'https://www.usue.ru/schedule/';

  void _configureDio() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    if (kDebugMode && !kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }

  void _initPipeline() {
    _querySubject
        .debounceTime(const Duration(milliseconds: 500))
        .switchMap((req) => Stream.fromFuture(_search(req.params))
            .map((r) => (req, r))
            .onErrorReturn((req, null)))
        .listen((result) {
      final (req, response) = result;

      if (!req.completer.isCompleted) {
        req.completer.complete(response);
      }
    });
  }

  Future<ScheduleResponse?> search(Params params) {
    final completer = Completer<ScheduleResponse?>();

    _querySubject.add(_SearchRequest(
      params: params,
      completer: completer,
    ));

    return completer.future;
  }

  Future<ScheduleResponse?> _search(Params p) async {
    try {
      return await getSchedule(
        startDate: p.startDate,
        endDate: p.endDate,
        scheduleModel: p.scheduleModel,
        force: p.forceUpdate,
      );
    } catch (e, st) {
      SessionLogger.instance.error(
        name,
        "Ошибка поиска расписания",
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<ScheduleResponse> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
    required ScheduleModel scheduleModel,
    bool force = false,
  }) async {
    SessionLogger.instance.debug(name, "Получение расписания", extra: {
      "Период": "${_formatDate(startDate)} - ${_formatDate(endDate)}",
      "Принудительный запрос": "$force"
    });

    final cached = force
        ? null
        : await cacheProvider?.getSchedule(scheduleModel, startDate, endDate);

    if (cached != null) return cached;

    final end =
        endDate.add(Duration(days: cacheProvider == null ? 0 : _prefetchDays));
    final start =
        startDate.subtract(Duration(days: cacheProvider == null ? 0 : 7));

    final params = {
      't': _generateTimestamp(),
      'action': 'show',
      'startDate': _formatDate(start),
      'endDate': _formatDate(end),
      scheduleModel.requestType.query: scheduleModel.queryValue,
    };

    final response = await _dio.get(_baseUrl, queryParameters: params);

    if (response.statusCode != 200) {
      throw Exception('Ошибка API: ${response.statusCode}');
    }

    final parsed = ScheduleResponse.parseFromApiResponse(response.data);

    cacheProvider?.saveSchedule(
      scheduleModel,
      parsed.fillEmptyDates(start, end,
          skip: scheduleModel.requestType != RequestType.audience),
    );

    return parsed.cut(startDate, endDate);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  String _generateTimestamp() {
    final random = Random();
    return '0.${List.generate(16, (_) => random.nextInt(10)).join()}';
  }
}

class _SearchRequest {
  final Params params;
  final Completer<ScheduleResponse?> completer;

  _SearchRequest({
    required this.params,
    required this.completer,
  });
}
