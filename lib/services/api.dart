import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:rxdart/rxdart.dart';

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
  final _querySubject = PublishSubject<Params>();
  final Dio _dio = Dio();
  final String _baseUrl = 'https://www.usue.ru/schedule/';

  ApiService() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  late final Stream<ScheduleResponse?> results = _querySubject
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap(
          (model) => Stream.fromFuture(_search(model)).onErrorResume((err, st) {
                debugPrint('Ошибка поиска: $err');
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

      debugPrint('Запрос к API: $_baseUrl');
      debugPrint('Параметры: $params');

      // Выполняем запрос
      final response = await _dio.get(
        _baseUrl,
        queryParameters: params,
      );

      // Парсим ответ
      if (response.statusCode == 200) {
        final scheduleResponse =
            ScheduleResponse.parseFromApiResponse(response.data);
        debugPrint(
            'Получено ${scheduleResponse.schedules.length} дней расписания');
        return scheduleResponse;
      } else {
        throw Exception('Ошибка API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ошибка при получении расписания: $e');
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
