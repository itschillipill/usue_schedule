import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usue_schedule/models/day_schedule.dart';
import '../core/utils/logger/session_logger.dart';
import '../models/schedule_response.dart';

import '../../models/schedule_model.dart';

abstract class CacheServiceBase {
  /// Сохраняет расписание для модели (может быть день или неделя)
  Future<void> saveSchedule(ScheduleModel model, ScheduleResponse response);

  /// Получает расписание для модели за указанный период
  Future<ScheduleResponse?> getSchedule(
      ScheduleModel model, DateTime start, DateTime end);

  /// Проверяет наличие расписания в кэше
  Future<bool> hasSchedule(ScheduleModel model, DateTime start, DateTime end);

  // --- Управление памятью ---

  /// Очищает старые данные
  Future<void> clearOldCache({Duration olderThan = const Duration(days: 30)});

  /// Очищает кэш для конкретной модели
  Future<void> clearModelCache(ScheduleModel model);

  /// Полная очистка кэша
  Future<void> clearAllCache();

  // --- Информация о кэше ---

  /// Возвращает информацию о том, что есть в кэше
  Future<Map<DateTime, Set<ScheduleModel>>> getAvailableCache();

  /// Размер кэша в байтах
  Future<int> getCacheSize();
}

final class CacheManager implements CacheServiceBase {
  static String name = "CacheManager";

  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  late final String _cacheDir;
  final Map<String, ScheduleModel> _activeModels = {};
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initCacheDirectory();
    await _loadActiveModels();
    SessionLogger.instance.onCreate(name);
  }

  Future<void> _initCacheDirectory() async {
    final dir = await getTemporaryDirectory();
    _cacheDir = '${dir.path}/schedule_cache';
    final cacheDir = Directory(_cacheDir);
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    SessionLogger.instance.log(name, "Cache directory initialized: ${cacheDir.path}");
  }

  Future<void> _loadActiveModels() async {
    final modelsJson = _prefs.getString('active_models');
    if (modelsJson != null) {
      final List<dynamic> decoded = jsonDecode(modelsJson);
      for (var item in decoded) {
        final model = ScheduleModel.fromJson(item);
        _activeModels[model.cacheKey] = model;
      }
    }
  }

  Future<void> _saveActiveModels() async {
    final modelsJson =
        jsonEncode(_activeModels.values.map((m) => m.toJson()).toList());
    await _prefs.setString('active_models', modelsJson);
  }

  String _dateKey(DateTime date) {
    return '${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
  }

  // Получаем файл для модели (один файл на модель)
  Future<File> _getModelFile(ScheduleModel model) async {
    final fileName = '${model.cacheKey}.json';
    return File('$_cacheDir/$fileName');
  }

  @override
  Future<void> saveSchedule(
      ScheduleModel model, ScheduleResponse response) async {
    if (response.schedules.isEmpty) return;

    final file = await _getModelFile(model);

    // Загружаем существующий кэш или создаем новый
    Map<String, dynamic> cacheData;
    if (await file.exists()) {
      final content = await file.readAsString();
      cacheData = jsonDecode(content);
    } else {
      cacheData = {
        'model': model.toJson(),
        'days': {}, // Здесь будут храниться дни по ключам
        'last_updated': DateTime.now().toIso8601String(),
      };
    }

    // Добавляем/обновляем каждый день из response
    for (var day in response.schedules) {
      // ставим пустой массив чтобы не заполнять пустыми данными
      if (!day.hasPairs) day = day.empty();

      final dateKey = _dateKey(day.date.toDateTime());
      cacheData['days'][dateKey] = day.toJson();
    }

    // Обновляем метаданные
    cacheData['last_updated'] = DateTime.now().toIso8601String();
    cacheData['days_count'] = (cacheData['days'] as Map).length;

    _activeModels[model.cacheKey] = model;

    // Сохраняем файл
    await file.writeAsString(jsonEncode(cacheData));
    await _saveActiveModels();

    SessionLogger.instance.debug(name, "Расписание успешно сохранено в кеш", extra: {
      "✅ Сохранено":"${response.schedules.length} дней в кэш для ${model.displayName}",
      "📊 Всего дней в кэше":"${cacheData['days_count']}"
    });
  }

  @override
  Future<ScheduleResponse?> getSchedule(
      ScheduleModel model, DateTime start, DateTime end) async {
    final file = await _getModelFile(model);

    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final cacheData = jsonDecode(content);

      // Нормализуем даты
      final normalizedStart = DateTime(start.year, start.month, start.day);
      final normalizedEnd = DateTime(end.year, end.month, end.day);

      // Собираем все дни в диапазоне
      final days = <DaySchedule>[];

      for (var date = normalizedStart;
          date.isBefore(normalizedEnd.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final dateKey = _dateKey(date);
        if (cacheData['days'].containsKey(dateKey)) {
          final dayJson = cacheData['days'][dateKey];
          days.add(DaySchedule.fromJson(dayJson));
        } else {
          // Если хотя бы одного дня нет - возвращаем null
          // (чтобы не отдавать неполные данные)
          return null;
        }
      }

      _activeModels[model.cacheKey] = model;
      await _saveActiveModels();
      SessionLogger.instance.log(name, '📦 Загружено ${days.length} дней из кэша для ${model.displayName}');

      return ScheduleResponse(schedules: days);
    } catch (e,s) {
      SessionLogger.instance.error(name, "❌ Ошибка чтения кэша", error: e, stackTrace: s);
      return null;
    }
  }

  @override
  Future<bool> hasSchedule(
      ScheduleModel model, DateTime start, DateTime end) async {
    final file = await _getModelFile(model);

    if (!await file.exists()) {
      return false;
    }

    try {
      final content = await file.readAsString();
      final cacheData = jsonDecode(content);

      final normalizedStart = DateTime(start.year, start.month, start.day);
      final normalizedEnd = DateTime(end.year, end.month, end.day);

      // Проверяем, есть ли все дни в диапазоне
      for (var date = normalizedStart;
          date.isBefore(normalizedEnd.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final dateKey = _dateKey(date);
        if (!cacheData['days'].containsKey(dateKey)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // --- Остальные методы с изменениями ---

  @override
  Future<void> clearModelCache(ScheduleModel model) async {
    final file = await _getModelFile(model);
    if (await file.exists()) {
      await file.delete();
    }

    _activeModels.remove(model.cacheKey);
    await _saveActiveModels();
    SessionLogger.instance.log(name, '🗑️ Очищен кэш для ${model.displayName}');
  }

  @override
  Future<Map<DateTime, Set<ScheduleModel>>> getAvailableCache() async {
    final result = <DateTime, Set<ScheduleModel>>{};
    final dir = Directory(_cacheDir);

    if (!await dir.exists()) return result;

    await for (var file in dir.list()) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content);

          if (data['last_updated'] != null && data['model'] != null) {
            final lastUpdated = DateTime.parse(data['last_updated']);
            final model = ScheduleModel.fromJson(data['model']);

            result.putIfAbsent(lastUpdated, () => {}).add(model);
          }
        } catch (e) {
          // Игнорируем битые файлы
        }
      }
    }

    return result;
  }

  // Вспомогательный метод для получения всех сохраненных дней модели
  Future<List<DateTime>> getAvailableDaysForModel(ScheduleModel model) async {
    final file = await _getModelFile(model);

    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content);

      final days = <DateTime>[];
      for (var dateKey in (data['days'] as Map).keys) {
        final parts = dateKey.split('_');
        if (parts.length == 3) {
          days.add(DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          ));
        }
      }

      return days..sort();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearOldCache(
      {Duration olderThan = const Duration(days: 30)}) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final dir = Directory(_cacheDir);

    if (!await dir.exists()) return;

    await for (var file in dir.list()) {
      if (file is File) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content);
          final lastUpdated = DateTime.parse(data['last_updated']);

          if (lastUpdated.isBefore(cutoff)) {
            await file.delete();
          }
        } catch (e) {
          // Если не можем прочитать - удаляем
          await file.delete();
        }
      }
    }
  }

  @override
  Future<void> clearAllCache() async {
    final dir = Directory(_cacheDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }
    _activeModels.clear();
    await _saveActiveModels();
    SessionLogger.instance.log(name,'🗑️ Весь кэш очищен');
  }

  @override
  Future<int> getCacheSize() async {
    int totalSize = 0;
    final dir = Directory(_cacheDir);

    if (!await dir.exists()) return 0;

    await for (var file in dir.list()) {
      if (file is File) {
        final stat = await file.stat();
        totalSize += stat.size;
      }
    }

    return totalSize;
  }
}

extension DateStringExtension on String {
  /// приведение строки в [DateTime]
  DateTime toDateTime() {
    final parts = split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid date format: $this');
    }
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }
}
