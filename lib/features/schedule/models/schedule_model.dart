import 'package:equatable/equatable.dart';

import 'schedule_type.dart';

class ScheduleModel extends Equatable implements Comparable<ScheduleModel> {
  const ScheduleModel({
    required this.scheduleType,
    required this.queryValue,
    this.lastUpdated,
  });

  // Тип запроса
  final ScheduleType scheduleType;

  // Значение запроса
  final String queryValue;

  // Последнее обновление
  final DateTime? lastUpdated;

  static const maxCacheAge = Duration(days: 3);

  // проверяем необходимость обновления, на случай если расписание обновили
  bool needsUpdate() {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated!) > maxCacheAge;
  }

  // сбрасываем последнее обновление
  ScheduleModel resetUpdate() => ScheduleModel(
        scheduleType: scheduleType,
        queryValue: queryValue,
        lastUpdated: null,
      );

  // Фабричные конструкторы
  factory ScheduleModel.teacher(String teacherName, {DateTime? lastUpdated}) {
    return ScheduleModel(
      scheduleType: ScheduleType.teacher,
      queryValue: teacherName,
      lastUpdated: lastUpdated,
    );
  }

  factory ScheduleModel.group(String groupName, {DateTime? lastUpdated}) {
    return ScheduleModel(
      scheduleType: ScheduleType.group,
      queryValue: groupName,
      lastUpdated: lastUpdated,
    );
  }

  factory ScheduleModel.audience(String audienceName, {DateTime? lastUpdated}) {
    return ScheduleModel(
      scheduleType: ScheduleType.audience,
      queryValue: audienceName,
      lastUpdated: lastUpdated,
    );
  }

  // Генерация ключа для кэша
  String get cacheKey {
    return '${scheduleType.name}_${_sanitizeKey(queryValue)}';
  }

  String _sanitizeKey(String value) {
    // \p{L} - любые буквы (включая русские)
    // \p{N} - любые цифры
    // \s - пробельные символы
    // \- - дефис
    // \. - точка
    return value.replaceAll(RegExp(r'[^\p{L}\p{N}\s\-\.]', unicode: true), '_');
  }

  // Для отображения
  String get displayName => '$scheduleType: $queryValue';

  // Сериализация
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      scheduleType:
          ScheduleType.values[json['scheduleType'] ?? json["requestType"]],
      queryValue: json['queryValue'].toString(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleType': scheduleType.index,
      'queryValue': queryValue,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  ScheduleModel update() => _copyWith(lastUpdated: DateTime.now());

  ScheduleModel _copyWith({
    ScheduleType? scheduleType,
    String? queryValue,
    DateTime? lastUpdated,
  }) =>
      ScheduleModel(
        scheduleType: scheduleType ?? this.scheduleType,
        queryValue: queryValue ?? this.queryValue,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  @override
  String toString() =>
      "ScheduleModel(scheduleType: ${scheduleType.name}, value: $queryValue, lastUpdated: $lastUpdated)";

  @override
  List<Object?> get props => [scheduleType, queryValue];

  // Сравнение для сортировки списка расписаний
  @override
  int compareTo(ScheduleModel other) {
    // null значения в конце
    if (lastUpdated == null && other.lastUpdated == null) return 0;
    if (lastUpdated == null) return 1;
    if (other.lastUpdated == null) return -1;

    // Сначала самые НОВЫЕ
    return other.lastUpdated!.compareTo(lastUpdated!);
  }
}
