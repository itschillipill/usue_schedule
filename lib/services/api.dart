import 'dart:io' show HttpClient;
import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:rxdart/rxdart.dart';
import 'package:usue_schedule/models/schedule_model.dart';

import '../controlles/cache_provider.dart';
import '../core/utils/logger/session_logger.dart';
import '../models/request_type.dart';
import '../models/schedule_response.dart';

typedef Params = ({
  DateTime startDate,
  DateTime endDate,
  ScheduleModel scheduleModel,
  bool forceUpdate,
});

// Сервис для работы с API
class ApiService {
  static const String name = "ApiService";
  static const int deafultPrefetchDays = 30;
  final int _prefetchDays;

  final _querySubject = PublishSubject<Params>();
  final CacheProvider? cacheProvider;
  late final Dio _dio;
  final String _baseUrl = 'https://www.usue.ru/schedule/';

  ApiService(
      {this.cacheProvider, Dio? dio, int prefetchDays = deafultPrefetchDays})
      : _prefetchDays = prefetchDays,
        _dio = dio ?? Dio() {
    if (dio == null) {
      _configureDio();
    }
  }

  void _configureDio() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Отключаем проверку сертификата (ТОЛЬКО ДЛЯ РАЗРАБОТКИ!)
    if (kDebugMode && !kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }

  late final Stream<ScheduleResponse?> results = _querySubject
      .debounceTime(const Duration(milliseconds: 500))
      .switchMap(
          (model) => Stream.fromFuture(_search(model)).onErrorResume((err, st) {
                SessionLogger.instance.error(
                    name, "Ошибка поиска расписания с параметрами: $model",
                    error: err, stackTrace: st);
                return Stream.value(null);
              }));

  void search(Params query) => _querySubject.add(query);

  Future<ScheduleResponse?> _search(Params p) async {
    return getSchedule(
      startDate: p.startDate,
      endDate: p.endDate,
      scheduleModel: p.scheduleModel,
      force: p.forceUpdate,
    );
  }

  // Основной метод получения расписания
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
    try {
      final response = force
          ? null
          : await cacheProvider?.getSchedule(scheduleModel, startDate, endDate);
      if (response != null) {
        return response;
      } else {
        final end = endDate
            // если нет в кеше, но при этом сам кеш сеществует,
            // за ранне загружаем месячное расписание но показываем только нужное
            .add(Duration(days: cacheProvider == null ? 0 : _prefetchDays));

        final start = startDate
            // делаем тоже самое и на неделю назад тоже (для страховки)
            .subtract(Duration(days: cacheProvider == null ? 0 : 7));

        // Форматируем даты в нужный формат
        final formattedEndDate = _formatDate(end);
        final formattedStartDate = _formatDate(start);

        // Генерируем timestamp (как в на официальном сайте)
        final timestamp = _generateTimestamp();

        // Параметры запроса
        final params = {
          't': timestamp,
          'action': 'show',
          'startDate': formattedStartDate,
          'endDate': formattedEndDate,
          scheduleModel.requestType.query: scheduleModel.queryValue,
        };

        SessionLogger.instance.debug(name, "Отправляем запрос к API",
            extra: {"Путь": _baseUrl, "Параметры": params.toString()});

        // Выполняем запрос
        final response = await _dio.get(
          _baseUrl,
          queryParameters: params,
        );

        // Парсим ответ
        if (response.statusCode == 200) {
          final scheduleResponse =
              ScheduleResponse.parseFromApiResponse(response.data);
          SessionLogger.instance.log(name,
              'Получено ${scheduleResponse.schedules.length} дней расписания');
          cacheProvider?.saveSchedule(
              scheduleModel,
              scheduleResponse.fillEmptyDates(start, end,
                  skip: scheduleModel.requestType != RequestType.audience));
          return scheduleResponse.cut(startDate, endDate);
        } else {
          throw Exception('Ошибка API: ${response.statusCode}');
        }
      }
    } catch (e, st) {
      SessionLogger.instance.error(name, 'Ошибка при получении расписания',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  // Метод для получения расписания на неделю
  Future<ScheduleResponse> getWeekSchedule({
    required DateTime startOfWeek,
    required ScheduleModel scheduleModel,
  }) async {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return getSchedule(
      startDate: startOfWeek,
      endDate: endOfWeek,
      scheduleModel: scheduleModel,
    );
  }

  // Метод для получения расписания на сегодня
  Future<ScheduleResponse> getTodaySchedule({
    required ScheduleModel scheduleModel,
  }) async {
    final today = DateTime.now();
    return getSchedule(
      startDate: today,
      endDate: today,
      scheduleModel: scheduleModel,
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
