import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:usue_schedule/features/schedule/models/day_schedule.dart';
import '../../../core/logger/session_logger.dart';
import '../../schedule/models/schedule_response.dart';

import '../../schedule/models/schedule_model.dart';

abstract class CacheServiceBase {
  /// Сохраняет расписание для модели (может быть день или неделя)
  Future<void> saveSchedule(ScheduleModel model, ScheduleResponse response);

  /// Получает расписание для модели за указанный период
  Future<ScheduleResponse?> getSchedule(
      ScheduleModel model, DateTime start, DateTime end);

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

  Future<void> init({String? cacheDir}) async {
    await _initCacheDirectory(cachePath: cacheDir);
    SessionLogger.instance.onCreate(name);
  }

  Future<void> _initCacheDirectory({String? cachePath}) async {
    final dir = await getTemporaryDirectory();
    _cacheDir = cachePath ?? '${dir.path}/schedule_cache';
    final cacheDir = Directory(_cacheDir);
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    SessionLogger.instance
        .log(name, "Cache directory initialized: ${cacheDir.path}");
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
    if (file.existsSync()) {
      final content = await file.readAsString();
      cacheData = jsonDecode(content);
    } else {
      cacheData = {
        'model': model.toJson(),
        'days': {}, // Здесь будут храниться дни по ключам
        'last_updated': "" // Здесь будет храниться время последнего обновления
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

    // Сохраняем файл
    try {
      await file.writeAsString(jsonEncode(cacheData));

      SessionLogger.instance
          .debug(name, "Расписание успешно сохранено в кеш", extra: {
        "✅ Сохранено":
            "${response.schedules.length} дней в кэш для ${model.displayName}",
        "📊 Всего дней в кэше": "${cacheData['days_count']}"
      });
    } catch (e) {
      SessionLogger.instance.error(name, "❌ Ошибка записи кэша", error: e);
    }
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

      // Собираем все дни в диапазоне
      final days = <DaySchedule>[];

      for (DateTime date = start;
          date.isBefore(end.add(const Duration(days: 1)));
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

      SessionLogger.instance.log(name,
          '📦 Загружено ${days.length} дней из кэша для ${model.displayName}');

      return ScheduleResponse(schedules: days, isFromCache: true);
    } catch (e, s) {
      SessionLogger.instance
          .error(name, "❌ Ошибка чтения кэша", error: e, stackTrace: s);
      return null;
    }
  }

  // --- Остальные методы с изменениями ---

  @override
  Future<void> clearModelCache(ScheduleModel model) async {
    try {
      final file = await _getModelFile(model);
      if (await file.exists()) {
        await file.delete();
      }

      SessionLogger.instance
          .log(name, '🗑️ Очищен кэш для ${model.displayName}');
    } catch (e) {
      SessionLogger.instance.error(name, "❌ Ошибка очистки кэша", error: e);
    }
  }

  @override
  Future<Map<DateTime, Set<ScheduleModel>>> getAvailableCache() async {
    final result = <DateTime, Set<ScheduleModel>>{};
    final dir = Directory(_cacheDir);

    if (!await dir.exists()) return result;

    await for (var fileEntity in dir.list()) {
      if (fileEntity case File file when file.path.endsWith('.json')) {
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
  Future<int> getAvailableDaysForModel(ScheduleModel model) async {
    try {
      final file = await _getModelFile(model);

      if (!await file.exists()) return 0;

      final content = await file.readAsString();
      final data = jsonDecode(content);
      return int.parse(data['days_count'].toString());
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> clearOldCache(
      {Duration olderThan = const Duration(days: 30)}) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final dir = Directory(_cacheDir);

    if (!await dir.exists()) return;

    await for (var fileEntity in dir.list()) {
      if (fileEntity case File file when file.path.endsWith('.json')) {
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
    SessionLogger.instance.log(name, '🗑️ Весь кэш очищен');
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
