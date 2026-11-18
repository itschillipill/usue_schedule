import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:usue_schedule/core/utils/date_utils.dart';
import 'package:usue_schedule/features/schedule/models/day_schedule.dart';
import '../../../core/logger/session_logger.dart';
import '../../schedule/models/schedule_response.dart';
import '../../schedule/models/schedule_model.dart';

abstract base class CacheServiceBase {
  /// Сохраняет расписание для модели (может быть день или неделя)
  Future<void> saveSchedule(ScheduleModel model, ScheduleResponse response);

  /// Получает расписание для модели за указанный период
  Future<ScheduleResponse?> getSchedule(
      ScheduleModel model, DateTime start, DateTime end);

  // --- Управление памятью ---

  /// Очищает данные
  Future<Map<String, dynamic>> clearCache(Map<String, dynamic> data);

  /// Очищает кэш для конкретной модели
  Future<void> clearModelCache(ScheduleModel model);

  /// Полная очистка кэша
  Future<void> clearAllCache();

  // --- Информация о кэше ---

  /// Возвращает информацию о том, что есть в кэше
  Future<({List<CacheInfo> info, String formattedSize})> getCacheInfo();

  /// Размер кэша в байтах
  Future<int> getCacheSize();
}

final class CacheManager implements CacheServiceBase {
  static String name = "CacheManager";

  /// Максимально допустимый размер для одного файла кэша.
  static const double maxFileSize = 2 * 1024 * 1024;

  /// Максимально допустимое количество дней.
  static const int maxDayCount = 150;

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

  String _dateKey(DateTime d) =>
      '${d.year}_${d.month.toString().padLeft(2, '0')}_${d.day.toString().padLeft(2, '0')}';

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

    // Создаем пустую структуру данных для сохранения
    Map<String, dynamic> emptyData = {
      'model': null,
      'days_count': 0, // Здесь будет храниться количество дней в кэше
      'days': {}, // Здесь будут храниться дни по ключам
    };

    // Загружаем существующий кэш или создаем новый
    Map<String, dynamic> cacheData = await (() async {
      if (!await file.exists()) return emptyData;
      try {
        return await _readJsonFile(file);
      } catch (_) {
        return emptyData;
      }
    })();

    // Добавляем/обновляем каждый день из response
    for (var day in response.schedules) {
      // ставим пустой массив чтобы не заполнять пустыми данными
      if (!day.hasPairs) day = day.empty();

      final dateKey = _dateKey(day.date);
      cacheData['days'][dateKey] = day.toJson();
    }

    // Обновляем метаданные
    cacheData['days_count'] = (cacheData['days'] as Map).length;
    cacheData['model'] = model.toJson();

    // Проверяем примерный размер будущей строки JSON.
    // Если он превышает лимит, запускаем очистку старых данных.
    String encodedData = jsonEncode(cacheData);
    if (cacheData['days_count'] > maxDayCount ||
        encodedData.length > maxFileSize) {
      cacheData = await clearCache(cacheData);
      encodedData = jsonEncode(cacheData);
    }

    // Сохраняем файл
    try {
      await file.writeAsString(encodedData);

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
      final cacheData = await _readJsonFile(file);

      // Собираем все дни в диапазоне
      final days = <DaySchedule>[];

      for (final date in DateTimeUtils.daysInRange(start, end)) {
        final dateKey = _dateKey(date);
        if (cacheData['days'].containsKey(dateKey)) {
          final dayJson = cacheData['days'][dateKey];
          days.add(DaySchedule.fromJson(dayJson));
        } else {
          // Если хотя бы одного дня нет - возвращаем null
          // (чтобы не отдавать неполные данные)
          SessionLogger.instance.log(name,
              "Не найдено расписания в кэше для ${model.displayName} для периода $start - $end");
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
  Future<({List<CacheInfo> info, String formattedSize})> getCacheInfo() async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) return (info: <CacheInfo>[], formattedSize: '0 B');

    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .cast<File>()
        .toList();

    final results = await Future.wait(files.map((file) async {
      try {
        final data = await _readJsonFile(file);
        if (data['model'] == null || data['days_count'] == null) {
          return null;
        }

        final size = await file.length();

        return (
          info: (
            model: ScheduleModel.fromJson(data['model']),
            daysCount: int.parse(data['days_count'].toString()),
          ),
          size: size,
        );
      } catch (e) {
        return null;
      }
    }));

    final validResults =
        results.whereType<({CacheInfo info, int size})>().toList();

    int totalSize = validResults.fold(0, (sum, item) => sum + item.size);

    final infoList = validResults.map((e) => e.info).toList()
      ..sort((a, b) => a.model.compareTo(b.model));

    return (
      info: infoList,
      formattedSize: switch (totalSize) {
        < 1024 => '$totalSize B',
        < 1024 * 1024 => '${(totalSize / 1024).toStringAsFixed(1)} KB',
        _ => '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB',
      },
    );
  }

  @override
  Future<Map<String, dynamic>> clearCache(Map<String, dynamic> data) async {
    final daysMap = data['days'] as Map<String, dynamic>?;
    if (daysMap == null || daysMap.isEmpty) return data;

    final now = DateTime.now();
    final keysToRemove = <String>[];

    daysMap.forEach((dateKey, value) {
      try {
        final parts = dateKey.split('_');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final date = DateTime(year, month, day);

          final difference = now.difference(date).inDays;
          if (difference > 60) {
            keysToRemove.add(dateKey);
          }
        }
      } catch (_) {
        // Если формат ключа поврежден — помечаем на удаление
        keysToRemove.add(dateKey);
      }
    });

    for (var key in keysToRemove) {
      daysMap.remove(key);
    }

    // Обновляем счетчик дней
    data['days_count'] = daysMap.length;
    SessionLogger.instance.log(name,
        '🧹 Очистка старого кэша выполнена. Осталось дней: ${daysMap.length}');

    return data;
  }

  @override
  Future<void> clearAllCache() async {
    final dir = Directory(_cacheDir);
    try {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (error, stackTrace) {
      SessionLogger.instance.error(name, 'Возникла ошибка при удалении кэша',
          error: error, stackTrace: stackTrace);
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

  /// Безопасное чтение и парсинг JSON в изоляте
  Future<Map<String, dynamic>> _readJsonFile(File file) async {
    if (!await file.exists()) return {};
    try {
      final content = await file.readAsString();
      if (content.isEmpty) return {};
      final decoded = await jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      return {};
    }
  }
}

typedef CacheInfo = ({
  ScheduleModel model,
  int daysCount,
});
