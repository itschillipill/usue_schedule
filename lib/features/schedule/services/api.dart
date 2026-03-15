import 'dart:async';
import 'dart:io' show HttpClient, SocketException;
import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:usue_schedule/core/api_exceptions.dart';

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
  Function(ScheduleModel model) onUpdateModel,
});

typedef _SearchRequest = ({
  Params params,
  Completer<ScheduleResponse?> completer,
});

class ApiService {
  static const String name = "ApiService";

  // количество дополнительных дней к кешируемому периоду
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
        .switchMap((req) => Stream.fromFuture(_fetchSchedule(req.params))
                .map((r) => (req, r))
                .onErrorReturnWith((error, stack) {
              req.completer.completeError(error);
              return (req, null);
            }))
        .listen((result) {
      final (req, response) = result;

      if (!req.completer.isCompleted) {
        req.completer.complete(response);
      }
    });
  }

  Future<ScheduleResponse?> fetch(Params params) async {
    final completer = Completer<ScheduleResponse?>();

    _querySubject.add((
      params: params,
      completer: completer,
    ));

    return completer.future;
  }

  Future<ScheduleResponse?> _fetchSchedule(Params p) async {
    try {
      return await getSchedule(
          startDate: p.startDate,
          endDate: p.endDate,
          scheduleModel: p.scheduleModel,
          force: p.forceUpdate,
          onUpdateModel: p.onUpdateModel);
    } catch (e, st) {
      SessionLogger.instance.error(
        name,
        "Ошибка поиска расписания",
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<ScheduleResponse> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
    required ScheduleModel scheduleModel,
    required Function(ScheduleModel model) onUpdateModel,
    bool force = false,
    ApiException? withException,
  }) async {
    SessionLogger.instance.debug(name, "Получение расписания", extra: {
      "Период": "${_formatDate(startDate)} - ${_formatDate(endDate)}",
      "Принудительный запрос": "$force"
    });

    try {
      // Проверка кэша
      final cached = force
          ? null
          : (await cacheProvider?.getSchedule(
                  scheduleModel, startDate, endDate))
              ?.withException(withException);

      if (cached != null) return cached;

      // Подготовка параметров
      final end = endDate
          .add(Duration(days: cacheProvider == null ? 0 : _prefetchDays));
      final start =
          startDate.subtract(Duration(days: cacheProvider == null ? 0 : 7));

      final params = {
        't': _generateT(),
        'action': 'show',
        'startDate': _formatDate(start),
        'endDate': _formatDate(end),
        scheduleModel.requestType.query: scheduleModel.queryValue,
      };

      late final Response response;

      try {
        response = await _dio.get(_baseUrl, queryParameters: params);
        // throw DioException(
        //     requestOptions: response.requestOptions,
        //     error: SocketException('simulated'));
      } on DioException catch (e) {
        late final ApiException apiException;

        if (e.error is SocketException) {
          apiException = NetworkException(e.error);
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          apiException = TimeoutException(e);
        } else if (e.response?.statusCode != null) {
          apiException = ServerException(e.response!.statusCode!, e);
        } else {
          apiException = UnknownException('Ошибка сети: ${e.message}', e);
        }

        if (force) {
          SessionLogger.instance.error(
            name,
            "Ошибка при force-запросе, пробуем без force",
            error: apiException,
          );
          return getSchedule(
            startDate: startDate,
            endDate: endDate,
            scheduleModel: scheduleModel,
            force: false,
            onUpdateModel: onUpdateModel,
            withException: apiException,
          );
        }

        throw apiException;
      }

      if (response.statusCode != 200) {
        throw ServerException(response.statusCode);
      }

      // Парсинг ответа
      late final ScheduleResponse parsed;
      try {
        parsed = ScheduleResponse.parseFromApiResponse(response.data);
      } catch (e, st) {
        SessionLogger.instance
            .error(name, "Ошибка парсинга ответа", error: e, stackTrace: st);
        throw ParseException(e);
      }

      // Сохранение в кэш
      try {
        cacheProvider?.saveSchedule(
          scheduleModel,
          parsed.fillEmptyDates(start, end,
              skip: scheduleModel.requestType != RequestType.audience),
        );
      } catch (e) {
        SessionLogger.instance
            .warning(name, "Ошибка сохранения в кэш", error: e);
      }

      onUpdateModel(scheduleModel.update());

      // возвращаем расписание только на заданный период,
      // без учета дополнительных дней для кеширования
      return parsed.cut(startDate, endDate);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      SessionLogger.instance
          .error(name, "Неожиданная ошибка", error: e, stackTrace: st);
      throw UnknownException('Неожиданная ошибка: $e', e);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  // генерируем t для запроса, как на офицальном сайте
  String _generateT() =>
      '0.${List<int>.generate(16, (_) => Random().nextInt(10)).join()}';
}
