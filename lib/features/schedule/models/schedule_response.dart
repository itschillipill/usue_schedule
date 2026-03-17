import 'dart:convert' show jsonDecode;

import 'package:equatable/equatable.dart';
import 'package:usue_schedule/core/api_exceptions.dart';
import 'package:usue_schedule/core/utils/date_utils.dart';
import 'day_schedule.dart';
import 'request_type.dart';

class ScheduleResponse extends Equatable {
  const ScheduleResponse(
      {required this.schedules, this.isFromCache = false, this.exception});

  // Список дней с расписанием
  final List<DaySchedule> schedules;

  // флаг который показывает из кэша ли расписание
  final bool isFromCache;

  // если есть ошибка
  final ApiException? exception;

  factory ScheduleResponse.fromJson(List<dynamic> json) {
    return ScheduleResponse(
      schedules: json.map((e) => DaySchedule.fromJson(e)).toList(),
    );
  }

  // Метод для парсинга из API ответа
  static ScheduleResponse parseFromApiResponse(dynamic responseData) {
    if (responseData is String) {
      return ScheduleResponse.fromJson(jsonDecode(responseData));
    } else if (responseData is List) {
      return ScheduleResponse.fromJson(responseData);
    } else {
      throw const FormatException('Некорректный формат данных от API');
    }
  }

  ScheduleResponse cut(DateTime startDate, DateTime endDate) {
    final filteredSchedules = schedules.where((day) {
      final dayDate = DateTimeUtils.parseDate(day.date);
      if (dayDate == null) return false;
      return dayDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          dayDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return ScheduleResponse(schedules: filteredSchedules);
  }

  // Получить все уникальные группы из расписания
  List<String> getAllGroups() =>
      schedules.expand((d) => d.getAllGroups()).toSet().toList();

  // Получить все уникальные преподаватели из расписания
  List<String> getAllTeachers() =>
      schedules.expand((d) => d.getAllTeachers()).toSet().toList();

  // Получить все уникальные аудитории
  List<String> getAllAudiences() =>
      schedules.expand((d) => d.getAllAudiences()).toSet().toList();

  // Отфильтровать по группе
  ScheduleResponse filterByGroup([String? groupName]) {
    if (groupName == null) return this;
    return ScheduleResponse(
      schedules: schedules
          .map((day) => day.filterByGroup(groupName))
          .where((day) => day.pairs.isNotEmpty)
          .toList(),
    );
  }

  ScheduleResponse getFiltredData(
    RequestType requestType,
    String? filter,
  ) {
    if (filter == null) return this;
    switch (requestType) {
      case RequestType.group:
        return filterByTeacher(filter);
      case RequestType.teacher:
        return filterByGroup(filter);
      default:
        return this;
    }
  }

  // Отфильтровать по преподавателю
  ScheduleResponse filterByTeacher([String? teacherName]) {
    if (teacherName == null) return this;
    return ScheduleResponse(
      schedules: schedules
          .map((day) => day.filterByTeacher(teacherName))
          .where((day) => day.pairs.isNotEmpty)
          .toList(),
    );
  }

  // Конвертировать в JSON (для сохранения в кэш)
  Map<String, dynamic> toJson() {
    return {
      'schedules': schedules.map((e) => e.toJson()).toList(),
    };
  }

  ScheduleResponse withException(ApiException? exception) => ScheduleResponse(
      schedules: schedules, isFromCache: isFromCache, exception: exception);

  factory ScheduleResponse.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return ScheduleResponse.fromJson(json['schedules']);
  }

  @override
  List<Object?> get props => [schedules];
}

extension ScheduleResponseFiller on ScheduleResponse {
  /// Заполняет пропущенные даты в указанном диапазоне пустыми днями
  ScheduleResponse fillEmptyDates(DateTime firstDate, DateTime lastDate,
      {bool skip = false}) {
    if (schedules.isEmpty || skip) return this;

    // Нормализуем даты (без времени)
    final normalizedStart =
        DateTime(firstDate.year, firstDate.month, firstDate.day);
    final normalizedEnd = DateTime(lastDate.year, lastDate.month, lastDate.day);

    // Создаем Map существующих дней для быстрого доступа
    // КЛЮЧ: дата в формате API "dd.mm.yyyy"
    final existingDays = <String, DaySchedule>{};
    for (var day in schedules) {
      existingDays[day.date] = day;
    }

    final filledSchedules = <DaySchedule>[];

    // Проходим по всем датам в диапазоне от первой до последней
    for (var date = normalizedStart;
        date.isBefore(normalizedEnd.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final apiDateStr =
          DateTimeUtils.formatDate(date, showWeekday: false); // "dd.mm.yyyy"
      final weekDay = DateTimeUtils.getWeekdayName(date.weekday);

      if (existingDays.containsKey(apiDateStr)) {
        filledSchedules.add(existingDays[apiDateStr]!);
      } else {
        filledSchedules.add(DaySchedule(
          date: apiDateStr,
          weekDay: weekDay,
          pairs: const [],
        ));
      }
    }
    return ScheduleResponse(schedules: filledSchedules);
  }
}
