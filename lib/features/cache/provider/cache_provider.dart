import 'package:flutter/foundation.dart';

import '../../schedule/models/schedule_model.dart';
import '../../schedule/models/schedule_response.dart';
import '../services/cache_service.dart';

class CacheProvider extends ChangeNotifier {
  final CacheManager _cacheManager = CacheManager();
  bool _isInitialized = false;
  String? cacheDir;
  Map<DateTime, Set<ScheduleModel>> _availableCache = {};

  CacheProvider({this.cacheDir}) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _cacheManager.init(cacheDir: cacheDir);
    _isInitialized = true;
    await refreshCacheInfo();
  }

  bool get isInitialized => _isInitialized;
  Map<DateTime, Set<ScheduleModel>> get availableCache => _availableCache;

  Future<void> refreshCacheInfo() async {
    _availableCache = await _cacheManager.getAvailableCache();
    notifyListeners();
  }

  /// Сохраняет расписание для модели (может быть день, неделя или произвольный период)
  Future<void> saveSchedule(
      ScheduleModel model, ScheduleResponse response) async {
    try {
      await _cacheManager.saveSchedule(model, response);
    } catch (e, st) {
      debugPrint("Erorr: $e, stacktrace: $st");
    }
    await refreshCacheInfo();
  }

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
    await refreshCacheInfo();
  }

  Future<void> clearAllCache() async {
    await _cacheManager.clearAllCache();
    await refreshCacheInfo();
  }

  Future<void> clearOldCache(
      {Duration olderThan = const Duration(days: 30)}) async {
    await _cacheManager.clearOldCache(olderThan: olderThan);
    await refreshCacheInfo();
  }

  // --- Информация о кэше ---

  Future<String> getCacheSizeFormatted() async {
    final size = await _cacheManager.getCacheSize();
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<int> getAvailableDaysForModel(ScheduleModel model) async {
    return _cacheManager.getAvailableDaysForModel(model);
  }

  Future<Map<DateTime, Set<ScheduleModel>>> getAvailableCache() async {
    return _cacheManager.getAvailableCache();
  }
}
