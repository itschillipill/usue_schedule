import 'dart:convert' show jsonDecode;

import 'day_schedule.dart';

class ScheduleResponse {
  final List<DaySchedule> schedules;

  ScheduleResponse({required this.schedules});

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
}
