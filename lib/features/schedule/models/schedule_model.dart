import 'package:equatable/equatable.dart';

import 'request_type.dart';

class ScheduleModel extends Equatable {
  const ScheduleModel({
    required this.requestType,
    required this.queryValue,
    this.lastUpdated,
  });

  // Тип запроса
  final RequestType requestType;

  // Значение запроса
  final String queryValue;

  // Последнее обновление
  final DateTime? lastUpdated;

  // проверяем необходимость обновления, на случай если данные устарели
  bool needsUpdate({Duration maxAge = const Duration(days: 2)}) {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated!) > maxAge;
  }

  // сбрасываем последнее обновление
  ScheduleModel resetUpdate() => ScheduleModel(
      requestType: requestType, queryValue: queryValue, lastUpdated: null);

  // Фабричные конструкторы
  factory ScheduleModel.teacher(String teacherName, {DateTime? lastUpdated}) {
    return ScheduleModel(
      requestType: RequestType.teacher,
      queryValue: teacherName,
      lastUpdated: lastUpdated,
    );
  }

  factory ScheduleModel.group(String groupName, {DateTime? lastUpdated}) {
    return ScheduleModel(
      requestType: RequestType.group,
      queryValue: groupName,
      lastUpdated: lastUpdated,
    );
  }

  factory ScheduleModel.audience(String audienceName, {DateTime? lastUpdated}) {
    return ScheduleModel(
      requestType: RequestType.audience,
      queryValue: audienceName,
      lastUpdated: lastUpdated,
    );
  }

  // Генерация ключа для кэша
  String get cacheKey {
    return '${requestType.name}_${_sanitizeKey(queryValue)}';
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
  String get displayName => '$requestType: $queryValue';

  // Сериализация
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      requestType: RequestType.values[json['requestType']],
      queryValue: json['queryValue'].toString(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestType': requestType.index,
      'queryValue': queryValue,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  ScheduleModel update() => ScheduleModel(
        requestType: requestType,
        queryValue: queryValue,
        lastUpdated: DateTime.now(),
      );

  @override
  String toString() =>
      "ScheduleModel(requestType: ${requestType.name}, value: $queryValue, lastUpdated: $lastUpdated)";

  @override
  List<Object?> get props => [requestType, queryValue];
}
