import 'dart:io' show HttpClient;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, ValueNotifier;
import 'package:usue_schedule/core/logger/session_logger.dart';
import 'package:usue_schedule/shared/mixins/debounce_mixin.dart';

import '../models/request_type.dart';
import '../models/schedule_model.dart';

class ScheduleSearchService with DebouncedRequestMixin {
  static const String name = "ScheduleSearchService";

  late final Dio _dio;

  final ValueNotifier<List<ScheduleModel>> resultsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isSearchingNotifier = ValueNotifier(false);

  ScheduleSearchService({Dio? dio}) {
    _dio = dio ??
        Dio(BaseOptions(
          baseUrl: 'https://www.usue.ru',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

    if (dio == null && kDebugMode && !kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }

  /// Метод поиска, вызываемый из TextField
  Future<void> search(ScheduleModel model) async {
    if (model.queryValue.isEmpty) {
      resultsNotifier.value = [];
      return;
    }

    isSearchingNotifier.value = true;

    try {
      final list = await debouncedRequest<List<ScheduleModel>?>(
        delay: const Duration(milliseconds: 500),
        action: () => _load(
          action: '${model.requestType.query}-list',
          query: model.queryValue,
          type: model.requestType,
        ),
      );

      if (list != null) {
        resultsNotifier.value = list;
      }
    } catch (e, st) {
      if (e is DioException && CancelToken.isCancel(e)) return;

      SessionLogger.instance
          .error(name, "Ошибка поиска", error: e, stackTrace: st);
      resultsNotifier.value = [];
    } finally {
      isSearchingNotifier.value = false;
    }
  }

  Future<List<ScheduleModel>> _load({
    required String action,
    required String query,
    required RequestType type,
  }) async {
    final response = await _dio.get(
      '/schedule/',
      queryParameters: {'action': action, 'term': query},
    );

    final List data = response.data;
    return data
        .map((e) => ScheduleModel(
              queryValue: type == RequestType.teacher && e is Map
                  ? e["label"].toString()
                  : e.toString(),
              requestType: type,
            ))
        .toList();
  }

  void dispose() {
    disposeDebounce();
    resultsNotifier.dispose();
    isSearchingNotifier.dispose();
  }
}
