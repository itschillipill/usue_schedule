import 'dart:io' show HttpClient;
import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:rxdart/rxdart.dart';
import 'package:usue_schedule/models/schedule_model.dart';

import '../controlles/cache_provider.dart';
import '../core/utils/logger/session_logger.dart';
import '../models/request_type.dart';
import '../models/schedule_response.dart';

typedef Params = (
  DateTime startDate,
  DateTime endDate,
  RequestType type,
  String queryValue
);

// Сервис для работы с API
class ApiService {
  static const String name = "ApiService";

  final _querySubject = PublishSubject<Params>();
  final CacheProvider? cacheProvider;
  final Dio _dio = Dio();
  final String _baseUrl = 'https://www.usue.ru/schedule/';

  ApiService({this.cacheProvider}) {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    if (kDebugMode) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }

  late final Stream<ScheduleResponse?> results = _querySubject
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap(
          (model) => Stream.fromFuture(_search(model)).onErrorResume((err, st) {
                SessionLogger.instance.error(name, "Ошибка поиска расписания с параметрами: $model", error: err, stackTrace: st);
                return Stream.value(null);
              }));

  void search(Params query) => _querySubject.add(query);

  Future<ScheduleResponse?> _search(Params p) async {
    return getSchedule(
      startDate: p.$1,
      endDate: p.$2,
      requestType: p.$3,
      queryValue: p.$4,
    );
  }

  // Основной метод получения расписания
  Future<ScheduleResponse> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
    required RequestType requestType,
    required String queryValue,
  }) async {
    try {
      final response = await cacheProvider?.getSchedule(
          ScheduleModel(requestType: requestType, queryValue: queryValue),
          startDate,
          endDate);
      if (response != null) {
        return response;
      } else {
        // Форматируем даты в нужный формат
        final formattedStartDate = _formatDate(startDate);
        final formattedEndDate = _formatDate(endDate);
        // Генерируем timestamp (как в примере)
        final timestamp = _generateTimestamp();

        // Параметры запроса
        final params = {
          't': timestamp,
          'action': 'show',
          'startDate': formattedStartDate,
          'endDate': formattedEndDate,
          requestType.query: queryValue,
        };

        SessionLogger.instance.debug(name, "Отправляем запрос к API", extra: {
          "Путь":_baseUrl,
          "Параметры":params.toString()
        });

        // Выполняем запрос
        final response = await _dio.get(
          _baseUrl,
          queryParameters: params,
        );

        // Парсим ответ
        if (response.statusCode == 200) {
          final scheduleResponse =
              ScheduleResponse.parseFromApiResponse(response.data);
          SessionLogger.instance.log(name, 'Получено ${scheduleResponse.schedules.length} дней расписания');
          cacheProvider?.saveSchedule(
              ScheduleModel(requestType: requestType, queryValue: queryValue),
              scheduleResponse);
          return scheduleResponse;
        } else {
          throw Exception('Ошибка API: ${response.statusCode}');
        }
      }
    } catch (e, st) {
      SessionLogger.instance.error(name, 'Ошибка при получении расписания', error: e, stackTrace: st);
      rethrow;
    }
  }

  // Метод для получения расписания на неделю
  Future<ScheduleResponse> getWeekSchedule({
    required DateTime startOfWeek,
    required RequestType requestType,
    required String queryValue,
  }) async {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return getSchedule(
      startDate: startOfWeek,
      endDate: endOfWeek,
      requestType: requestType,
      queryValue: queryValue,
    );
  }

  // Метод для получения расписания на сегодня
  Future<ScheduleResponse> getTodaySchedule({
    required RequestType requestType,
    required String queryValue,
  }) async {
    final today = DateTime.now();
    return getSchedule(
      startDate: today,
      endDate: today,
      requestType: requestType,
      queryValue: queryValue,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  String _generateTimestamp() {
    final random = Random();
    final digits = StringBuffer();

    for (int i = 0; i < 16; i++) {
      digits.write(random.nextInt(10));
    }

    return '0.$digits';
  }
}
