
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_schedule.dart';
import '../models/schedule_response.dart';
import '../models/request_type.dart';

class CacheService {
  static const String _cachePrefix = 'schedule_cache_';
  static const Duration _cacheDuration = Duration(hours: 1);
  static const int _maxCacheSize = 50; // Максимальное количество кэшированных дней

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  // Генерируем ключ для кэша
  String _generateCacheKey({
    required DateTime date,
    required RequestType type,
    required String queryValue,
  }) {
    final dateStr = _formatDateForCache(date);
    final typeStr = type.name;
    final queryHash = _generateQueryHash(queryValue);
    
    return '$_cachePrefix${dateStr}_${typeStr}_$queryHash';
  }

  // Генерируем ключ для недели
  String _generateWeekCacheKey({
    required DateTime startDate,
    required RequestType type,
    required String queryValue,
  }) {
    final startDateStr = _formatDateForCache(startDate);
    final typeStr = type.name;
    final queryHash = _generateQueryHash(queryValue);
    
    return '${_cachePrefix}week_${startDateStr}_${typeStr}_$queryHash';
  }

  String _formatDateForCache(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _generateQueryHash(String query) {
    return query.hashCode.toRadixString(16);
  }

  // Сохраняем расписание на день
  Future<void> cacheSchedule({
    required DateTime date,
    required RequestType type,
    required String queryValue,
    required ScheduleResponse response,
  }) async {
    try {
      final key = _generateCacheKey(date: date, type: type, queryValue: queryValue);
      final value = json.encode(response.toJson());
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final cacheData = {
        'data': value,
        'timestamp': timestamp,
        'date': date.toIso8601String(),
        'type': type.name,
        'query': queryValue,
      };
      
      await _prefs.setString(key, json.encode(cacheData));
      
      // Очищаем старый кэш если нужно
      await _cleanOldCache();
      
      debugPrint('Кэшировано расписание на $date для $queryValue');
    } catch (e) {
      debugPrint('Ошибка кэширования: $e');
    }
  }

  // Получаем расписание из кэша
  Future<ScheduleResponse?> getCachedSchedule({
    required DateTime date,
    required RequestType type,
    required String queryValue,
  }) async {
  final key = _generateCacheKey(date: date, type: type, queryValue: queryValue);
    try {
      final cachedString = _prefs.getString(key);
      
      if (cachedString == null) return null;
      
      final cacheData = json.decode(cachedString);
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      // Проверяем не устарели ли данные
      if (DateTime.now().difference(cacheTime) > _cacheDuration) {
        await _prefs.remove(key);
        return null;
      }
      
      final responseData = json.decode(cacheData['data']);
      final response = ScheduleResponse.fromJson(responseData);
      
      debugPrint('Загружено из кэша расписание на $date для $queryValue');
      return response;
    } catch (e) {
      debugPrint('Ошибка чтения кэша: $e');
      await _prefs.remove(key);
      return null;
    }
  }

  // Получаем расписание на неделю из кэшированных дней
  Future<ScheduleResponse?> getCachedWeekSchedule({
    required DateTime startDate,
    required RequestType type,
    required String queryValue,
  }) async {
    try {
      final days = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        days.add(startDate.add(Duration(days: i)));
      }
      
      final cachedDays = <ScheduleResponse>[];
      
      for (final day in days) {
        final cached = await getCachedSchedule(
          date: day,
          type: type,
          queryValue: queryValue,
        );
        
        if (cached != null) {
          cachedDays.add(cached);
        } else {
          // Если хоть одного дня нет в кэше, не возвращаем неделю
          return null;
        }
      }
      
      // Объединяем все дни в одно расписание
      final allSchedules = <DaySchedule>[];
      for (final response in cachedDays) {
        allSchedules.addAll(response.schedules);
      }
      
      return ScheduleResponse(schedules: allSchedules);
    } catch (e) {
      debugPrint('Ошибка получения недели из кэша: $e');
      return null;
    }
  }

  // Кэшируем сразу всю неделю (опционально)
  Future<void> cacheWeekSchedule({
    required DateTime startDate,
    required RequestType type,
    required String queryValue,
    required ScheduleResponse response,
  }) async {
    try {
      final key = _generateWeekCacheKey(
        startDate: startDate,
        type: type,
        queryValue: queryValue,
      );
      
      final value = json.encode(response.toJson());
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final cacheData = {
        'data': value,
        'timestamp': timestamp,
        'startDate': startDate.toIso8601String(),
        'type': type.name,
        'query': queryValue,
      };
      
      await _prefs.setString(key, json.encode(cacheData));
      debugPrint('Кэширована неделя с $startDate для $queryValue');
    } catch (e) {
      debugPrint('Ошибка кэширования недели: $e');
    }
  }

  // Очистка старого кэша
  Future<void> _cleanOldCache() async {
    try {
      final allKeys = _prefs.getKeys().where((key) => key.startsWith(_cachePrefix)).toList();
      
      if (allKeys.length <= _maxCacheSize) return;
      
      // Сортируем по времени последнего доступа
      final cacheEntries = <Map<String, dynamic>>[];
      
      for (final key in allKeys) {
        final cachedString = _prefs.getString(key);
        if (cachedString != null) {
          try {
            final cacheData = json.decode(cachedString);
            cacheEntries.add({
              'key': key,
              'timestamp': cacheData['timestamp'] as int,
            });
          } catch (_) {}
        }
      }
      
      // Сортируем по времени (старые первыми)
      cacheEntries.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      
      // Удаляем самые старые записи
      final toRemove = cacheEntries.length - _maxCacheSize;
      for (int i = 0; i < toRemove; i++) {
        await _prefs.remove(cacheEntries[i]['key']);
      }
      
      debugPrint('Очищен кэш: удалено $toRemove записей');
    } catch (e) {
      debugPrint('Ошибка очистки кэша: $e');
    }
  }

  // Очистка всего кэша
  Future<void> clearCache() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_cachePrefix)).toList();
      
      for (final key in keys) {
        await _prefs.remove(key);
      }
      
      debugPrint('Весь кэш очищен');
    } catch (e) {
      debugPrint('Ошибка очистки кэша: $e');
    }
  }

  // Получить размер кэша
  Future<int> getCacheSize() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_cachePrefix)).toList();
      int totalSize = 0;
      
      for (final key in keys) {
        final value = _prefs.getString(key);
        if (value != null) {
          totalSize += value.length * 2; // Примерный размер в байтах
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Ошибка получения размера кэша: $e');
      return 0;
    }
  }

  // Получить информацию о кэше
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_cachePrefix)).toList();
      final now = DateTime.now();
      
      int totalEntries = 0;
      int validEntries = 0;
      final oldestDate = DateTime.now();
      DateTime? newestDate;
      
      for (final key in keys) {
        final cachedString = _prefs.getString(key);
        if (cachedString != null) {
          totalEntries++;
          
          try {
            final cacheData = json.decode(cachedString);
            final timestamp = cacheData['timestamp'] as int;
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            
            if (now.difference(cacheTime) <= _cacheDuration) {
              validEntries++;
            }
            
            if (cacheTime.isBefore(oldestDate)) {
              // Для oldestDate нужна отдельная логика
            }
            if (newestDate == null || cacheTime.isAfter(newestDate)) {
              newestDate = cacheTime;
            }
          } catch (_) {}
        }
      }
      
      return {
        'totalEntries': totalEntries,
        'validEntries': validEntries,
        'cacheSize': await getCacheSize(),
        'maxSize': _maxCacheSize,
        'cacheDuration': _cacheDuration,
      };
    } catch (e) {
      debugPrint('Ошибка получения информации о кэше: $e');
      return {};
    }
  }
}