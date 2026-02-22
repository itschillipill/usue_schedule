import 'package:flutter/foundation.dart';

import '../models/schedule_model.dart';
import '../models/schedule_response.dart';
import '../services/cache_service.dart';

class CacheProvider extends ChangeNotifier {
  final CacheManager _cacheManager = CacheManager();
  bool _isInitialized = false;
  Map<DateTime, Set<ScheduleModel>> _availableCache = {};

  CacheProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _cacheManager.init();
    _isInitialized = true;
    await refreshCacheInfo();
  }

  bool get isInitialized => _isInitialized;
  Map<DateTime, Set<ScheduleModel>> get availableCache => _availableCache;

  Future<void> refreshCacheInfo() async {
    _availableCache = await _cacheManager.getAvailableCache();
    notifyListeners();
  }

  // --- ЕДИНЫЕ МЕТОДЫ для работы с кэшем ---

  /// Сохраняет расписание для модели (может быть день или неделя)
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

  /// Проверяет наличие расписания в кэше
  Future<bool> hasSchedule(
      ScheduleModel model, DateTime start, DateTime end) async {
    return _cacheManager.hasSchedule(model, start, end);
  }

  // --- Управление кэшем ---

  Future<void> clearModelCache(ScheduleModel model) async {
    await _cacheManager.clearModelCache(model);
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

  // --- Вспомогательные методы для удобства ---

  /// Получить расписание на один день (обертка над getSchedule)
  Future<ScheduleResponse?> getDaySchedule(
      ScheduleModel model, DateTime date) async {
    return getSchedule(model, date, date);
  }

  /// Получить расписание на неделю (обертка над getSchedule)
  Future<ScheduleResponse?> getWeekSchedule(
      ScheduleModel model, DateTime startOfWeek) async {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return getSchedule(model, startOfWeek, endOfWeek);
  }

  /// Сохранить расписание на неделю (обертка над saveSchedule)
  Future<void> saveWeekSchedule(
      ScheduleModel model, ScheduleResponse weekResponse) async {
    await saveSchedule(model, weekResponse);
  }

  // Добавить в CacheProvider метод для получения дней модели
  Future<List<DateTime>> getAvailableDaysForModel(ScheduleModel model) async {
    return _cacheManager.getAvailableDaysForModel(model);
  }

  Future<Map<DateTime, Set<ScheduleModel>>> getAvailableCache() async {
    return _cacheManager.getAvailableCache();
  }
}
