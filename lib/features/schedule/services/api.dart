import 'dart:async';
import 'dart:io' show HttpClient, SocketException;
import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart';
import 'package:usue_schedule/core/api_exceptions.dart';
import 'package:usue_schedule/shared/mixins/debounce_mixin.dart';

import '../../../core/logger/session_logger.dart';
import '../../cache/provider/cache_provider.dart';
import '../models/schedule_type.dart';
import '../models/schedule_model.dart';
import '../models/schedule_response.dart';

class ApiService with DebouncedRequestMixin {
  static const String name = "ApiService";

  // количество дополнительных дней к кешируемому периоду
  static const int defaultPrefetchDays = 30;

  final int _prefetchDays;

  final CacheProvider? _cacheProvider;

  final Dio _dio;

  ApiService({
    CacheProvider? cacheProvider,
    Dio? dio,
    int prefetchDays = defaultPrefetchDays,
  })  : _prefetchDays = prefetchDays,
        _cacheProvider = cacheProvider,
        _dio = dio ?? Dio() {
    if (dio == null) {
      _configureDio();
    }
  }

  final String _baseUrl = 'https://www.usue.ru/schedule/';

  void _configureDio() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    if (!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }

  Future<ScheduleResponse?> fetch({
    required DateTime startDate,
    required DateTime endDate,
    required ScheduleModel scheduleModel,
    required bool forceUpdate,
    required Function(ScheduleModel model) onUpdateModel,
    bool saveSchedule = true,
  }) async {
    try {
      return await debouncedRequest<ScheduleResponse?>(
          delay: Duration(milliseconds: 350),
          action: () => getSchedule(
              startDate: startDate,
              endDate: endDate,
              scheduleModel: scheduleModel,
              force: forceUpdate,
              onUpdateModel: onUpdateModel,
              saveSchedule: saveSchedule));
    } catch (e, st) {
      if (e case DioException error when CancelToken.isCancel(error)) {
        return null;
      }
      SessionLogger.instance
          .error(name, "Ошибка получения расписания", error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<ScheduleResponse> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
    required ScheduleModel scheduleModel,
    required Function(ScheduleModel model) onUpdateModel,
    bool force = false,
    bool saveSchedule = true,
    ApiException? withException,
  }) async {
    SessionLogger.instance.debug(name, "Получение расписания", extra: {
      "Период": "${_formatDate(startDate)} - ${_formatDate(endDate)}",
      "Принудительный запрос": "$force"
    });

    try {
      // Подготовка параметров
      final end = endDate
          .add(Duration(days: _cacheProvider == null ? 0 : _prefetchDays));
      final start =
          startDate.subtract(Duration(days: _cacheProvider == null ? 0 : 7));

      // Проверка кэша
      final cached = force
          ? null
          : (await _cacheProvider?.getSchedule(scheduleModel, start, end))
              ?.copyWith(exception: withException);

      if (cached != null) return cached;

      final params = {
        't': _generate$T(),
        'action': 'show',
        'startDate': _formatDate(start),
        'endDate': _formatDate(end),
        scheduleModel.scheduleType.query: scheduleModel.queryValue,
      };

      late final Response response;

      try {
        response = await _dio.get(_baseUrl, queryParameters: params);
        // throw DioException(
        //     requestOptions: response.requestOptions,
        //     error: SocketException('simulated'));
      } on DioException catch (e) {
        final apiException = switch (e) {
          _ when e.error is SocketException => NetworkException(e.error),
          _
              when e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout =>
            TimeoutException(e),
          _ when e.response?.statusCode != null =>
            ServerException(e.response!.statusCode!, e),
          _ => UnknownException(
              "Ошибка сети: ${e.message ?? defaultDioExceptionReadableStringBuilder(e)}",
              e),
        };

        if (force) {
          SessionLogger.instance.error(
            name,
            "Ошибка при force-запросе, пробуем без force",
            error: apiException,
          );
          return await getSchedule(
            startDate: startDate,
            endDate: endDate,
            scheduleModel: scheduleModel,
            force: false,
            saveSchedule: saveSchedule,
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
      if (saveSchedule) {
        try {
          ScheduleModel? updatedModel;

          if (scheduleModel.needsUpdate() || force) {
            updatedModel = scheduleModel.update();
            onUpdateModel(updatedModel);
          }

          saveCachedSchedule(
            updatedModel ?? scheduleModel,
            parsed.fillEmptyDates(start, end,
                skip: scheduleModel.scheduleType != ScheduleType.audience),
          );
        } catch (e) {
          SessionLogger.instance
              .warning(name, "Ошибка сохранения в кэш", error: e);
        }
      }

      return parsed;
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

  void saveCachedSchedule(ScheduleModel model, ScheduleResponse resp) =>
      _cacheProvider?.saveSchedule(model, resp);

  // генерируем t для запроса, как на офицальном сайте
  String _generate$T() =>
      '0.${List<int>.generate(16, (_) => Random().nextInt(10), growable: false).join()}';
}
