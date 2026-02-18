import 'request_type.dart';

// lib/models/schedule_model.dart
import 'package:equatable/equatable.dart';

class ScheduleModel extends Equatable {
  final RequestType requestType;
  final String queryValue;

  const ScheduleModel({
    required this.requestType,
    required this.queryValue,
  });

  // Фабричные конструкторы
  factory ScheduleModel.teacher(String teacherName) {
    return ScheduleModel(
      requestType: RequestType.teacher,
      queryValue: teacherName,
    );
  }

  factory ScheduleModel.group(String groupName) {
    return ScheduleModel(
      requestType: RequestType.group,
      queryValue: groupName,
    );
  }

  factory ScheduleModel.audience(String audienceName) {
    return ScheduleModel(
      requestType: RequestType.audience,
      queryValue: audienceName,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestType': requestType.index,
      'queryValue': queryValue,
    };
  }

  @override
  List<Object?> get props => [requestType, queryValue];
}
