import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:usue_schedule/core/logger/session_logger.dart';
import 'package:usue_schedule/core/network/dio_factory.dart';
import 'package:usue_schedule/shared/mixins/debounce_mixin.dart';

import '../models/schedule_type.dart';
import '../models/schedule_model.dart';

class ScheduleSearchService with DebouncedRequestMixin {
  static const String name = "ScheduleSearchService";

  late final Dio _dio;

  final ValueNotifier<List<ScheduleModel>> resultsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isSearchingNotifier = ValueNotifier(false);

  ScheduleSearchService({Dio? dio}) {
    _dio = dio ?? DioFactory.createDio(baseUrl: 'https://www.usue.ru/');
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
        delay: const Duration(milliseconds: 350),
        action: () => _load(
          action: '${model.scheduleType.query}-list',
          query: model.queryValue,
          type: model.scheduleType,
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
    required ScheduleType type,
  }) async {
    final response = await _dio.get(
      '/schedule/',
      queryParameters: {'action': action, 'term': query},
    );

    final List data = response.data;
    return data
        .map((e) => ScheduleModel(
              queryValue: type == ScheduleType.teacher && e is Map
                  ? e["label"].toString()
                  : e.toString(),
              scheduleType: type,
            ))
        .toList();
  }

  void dispose() {
    disposeDebounce();
    resultsNotifier.dispose();
    isSearchingNotifier.dispose();
  }
}
