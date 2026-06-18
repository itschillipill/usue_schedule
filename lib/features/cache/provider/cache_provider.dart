import 'package:flutter/foundation.dart';

import '../../schedule/models/schedule_model.dart';
import '../../schedule/models/schedule_response.dart';
import '../services/cache_service.dart';

class CacheProvider extends ChangeNotifier {
  final CacheManager _cacheManager = CacheManager();
  final String? cacheDir;

  CacheProvider._({this.cacheDir});

  static Future<CacheProvider?> create({String? cacheDir}) async {
    if (kIsWeb) return null;
    final provider = CacheProvider._(cacheDir: cacheDir);
    if (!await provider._initialize()) return null;
    return provider;
  }

  Future<bool> _initialize() async {
    try {
      await _cacheManager.init(cacheDir: cacheDir);
    } catch (error, stackTrace) {
      debugPrint(
          "Error initializing cache provider : $error, stacktrace: $stackTrace");
      return false;
    }
    return true;
  }

  /// Сохраняет расписание для модели (может быть день, неделя или произвольный период)
  Future<void> saveSchedule(ScheduleModel model, ScheduleResponse response) =>
      _cacheManager.saveSchedule(model, response);

  /// Получает расписание для модели за указанный период
  Future<ScheduleResponse?> getSchedule(
      ScheduleModel model, DateTime start, DateTime end) async {
    final result = await _cacheManager.getSchedule(model, start, end);
    return result;
  }

  // --- Управление кэшем ---

  Future<void> clearModelsCache(List<ScheduleModel> models) async {
    for (final model in models) {
      await _cacheManager.clearModelCache(model);
    }
  }

  Future<void> clearAllCache() => _cacheManager.clearAllCache();

  Future<void> clearOldCache(
      {Duration olderThan = const Duration(days: 30)}) async {
    await _cacheManager.clearOldCache(olderThan: olderThan);
  }

  // --- Информация о кэше ---
  Future<int> getAvailableDaysForModel(ScheduleModel model) async {
    return _cacheManager.getAvailableDaysForModel(model);
  }

  Future<({List<CacheInfo> info, String formattedSize})> getCacheInfo() {
    return _cacheManager.getCacheInfo();
  }
}
