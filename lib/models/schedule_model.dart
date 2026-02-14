import 'request_type.dart';

class ScheduleModel {
  final RequestType requestType;
  final String queryValue;

  ScheduleModel({required this.requestType, required this.queryValue});

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
  int get hashCode => requestType.hashCode ^ queryValue.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleModel) return false;
    return requestType == other.requestType && queryValue == other.queryValue;
  }
}
