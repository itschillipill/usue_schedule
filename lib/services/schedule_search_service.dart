import 'dart:io' show HttpClient;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:rxdart/rxdart.dart';
import 'package:usue_schedule/core/utils/logger/session_logger.dart';

import '../models/request_type.dart';
import '../models/schedule_model.dart';

class ScheduleSearchService {
  static const String name = "ScheduleSearchService";

  late final Dio _dio;
  final _querySubject = PublishSubject<ScheduleModel>();

  ScheduleSearchService({Dio? dio}) {
    _dio = dio ??
        Dio(BaseOptions(
          baseUrl: 'https://www.usue.ru',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

    // Отключаем проверку сертификата (ТОЛЬКО ДЛЯ РАЗРАБОТКИ!)
    if (kDebugMode && !kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }

  late final Stream<List<ScheduleModel>> results = _querySubject
      .debounceTime(const Duration(milliseconds: 300))
      .distinct((a, b) =>
          a.queryValue == b.queryValue && a.requestType == b.requestType)
      .switchMap((model) => Stream.fromFuture(_search(model)).onErrorResume(
            (err, st) {
              SessionLogger.instance.error(name, "Ошибка поиска расписаний",
                  error: err, stackTrace: st);
              return Stream.value([]);
            },
          ));

  void search(ScheduleModel query) => _querySubject.add(query);

  Future<List<ScheduleModel>> _search(ScheduleModel model) async {
    return _load(
      action: '${model.requestType.query}-list',
      query: model.queryValue,
      type: model.requestType,
    );
  }

  Future<List<ScheduleModel>> _load({
    required String action,
    required String query,
    required RequestType type,
  }) async {
    try {
      final response = await _dio.get(
        '/schedule/',
        queryParameters: {
          'action': action,
          'term': query,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final List data = response.data;

      return data
          .map((e) => ScheduleModel(
                queryValue: switch (type) {
                  RequestType.teacher when e is Map<String, dynamic> =>
                    e["label"].toString(),
                  _ => e.toString(),
                },
                requestType: type,
              ))
          .toList();
    } catch (error, stackTrace) {
      SessionLogger.instance
          .error(name, "Ошибка загрузки", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  void dispose() => _querySubject.close();
}
