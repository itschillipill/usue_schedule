import 'dart:convert' show jsonDecode;

import 'package:equatable/equatable.dart';
import 'package:usue_schedule/core/utils/date_utils.dart';

import '../services/cache_service.dart';
import 'day_schedule.dart';

class ScheduleResponse extends Equatable{
  final List<DaySchedule> schedules;

  const ScheduleResponse({required this.schedules});

  factory ScheduleResponse.fromJson(List<dynamic> json) {
    return ScheduleResponse(
      schedules: json.map((e) => DaySchedule.fromJson(e)).toList(),
    );
  }

  ScheduleResponse filterResponseByGroup(String? selectedGroupFilter) {
    if (selectedGroupFilter == null) return this;

    return ScheduleResponse(
      schedules: schedules
          .map((day) => day.filterByGroup(selectedGroupFilter))
          .where((day) => day.hasPairs)
          .toList(),
    );
  }

  ScheduleResponse filterResponseByTeacher(String? selectedTeacherFilter) {
    if (selectedTeacherFilter == null) return this;

    return ScheduleResponse(
      schedules: schedules
          .map((day) => day.filterByTeacher(selectedTeacherFilter))
          .where((day) => day.hasPairs)
          .toList(),
    );
  }

  // Метод для парсинга из API ответа
  static ScheduleResponse parseFromApiResponse(dynamic responseData) {
    if (responseData is String) {
      return ScheduleResponse.fromJson(jsonDecode(responseData));
    } else if (responseData is List) {
      return ScheduleResponse.fromJson(responseData);
    } else {
      throw FormatException('Некорректный формат данных от API');
    }
  }

  ScheduleResponse cut(DateTime startDate, DateTime endDate) {
    final normalizedStart =
        DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

    final filteredSchedules = schedules.where((day) {
      final dayDate = day.date.toDateTime(); // используем ваш метод парсинга
      return dayDate
              .isAfter(normalizedStart.subtract(const Duration(days: 1))) &&
          dayDate.isBefore(normalizedEnd.add(const Duration(days: 1)));
    }).toList();

    return ScheduleResponse(schedules: filteredSchedules);
  }

  // Получить все уникальные группы из расписания
  List<String> getAllGroups() {
    final groups = <String>{};
    for (var day in schedules) {
      for (var group in day.getAllGroups()) {
        groups.add(group);
      }
    }
    return groups.toList()..sort();
  }

  // Получить все уникальные преподаватели из расписания
  List<String> getAllTeachers() {
    final teachers = <String>{};
    for (var day in schedules) {
      for (var teacher in day.getAllTeachers()) {
        teachers.add(teacher);
      }
    }
    return teachers.toList()..sort();
  }

  // Получить все уникальные аудитории
  List<String> getAllAudiences() {
    final audiences = <String>{};
    for (var day in schedules) {
      for (var audience in day.getAllAudiences()) {
        audiences.add(audience);
      }
    }
    return audiences.toList()..sort();
  }

  // Отфильтровать по группе
  ScheduleResponse filterByGroup(String groupName) {
    return ScheduleResponse(
      schedules: schedules
          .map((day) => day.filterByGroup(groupName))
          .where((day) => day.pairs.isNotEmpty)
          .toList(),
    );
  }

  // Отфильтровать по преподавателю
  ScheduleResponse filterByTeacher(String teacherName) {
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
          pairs: [],
        ));
      }
    }
    return ScheduleResponse(schedules: filledSchedules);
  }
}
