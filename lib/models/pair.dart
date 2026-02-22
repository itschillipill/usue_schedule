import 'package:equatable/equatable.dart';

import 'pair_time.dart';
import 'schedule_pair.dart';

class Pair extends Equatable{
  final int number;
  final String time;
  final List<SchedulePair> schedulePairs;

  const Pair({
    required this.number,
    required this.time,
    required this.schedulePairs,
  });

  factory Pair.fromJson(Map<String, dynamic> json) {
    return Pair(
      number: json['N'] as int? ?? 1,
      time: json['time'] as String? ?? '',
      schedulePairs: (json['schedulePairs'] as List<dynamic>?)
              ?.map((e) => SchedulePair.fromJson(e))
              .toList() ??
          [],
    );
  }

  (String startTime, String endTime) get timeRange {
    final parts = time.split('-');
    if (parts.length == 2) {
      return (parts[0].trim(), parts[1].trim());
    }
    return ('', '');
  }

  bool isCurrentPair(DateTime date) =>
      PairTime.isCurrentPair(number, date: date);

  List<String> getAllGroups() {
    return schedulePairs.map((sp) => sp.group).toSet().toList();
  }

  List<String> getAllTeachers() {
    return schedulePairs.map((sp) => sp.teacher).toSet().toList();
  }

  List<String> getAllAudiences() {
    return schedulePairs.map((sp) => sp.audience).toSet().toList();
  }

  Pair filterByGroup(String groupName) {
    final filtered =
        schedulePairs.where((sp) => sp.cleanGroup == groupName).toList();

    return Pair(
      number: number,
      time: time,
      schedulePairs: filtered,
    );
  }

  Pair filterByTeacher(String teacherName) {
    final filtered =
        schedulePairs.where((sp) => sp.teacher.contains(teacherName)).toList();

    return Pair(
      number: number,
      time: time,
      schedulePairs: filtered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'N': number,
      'time': time,
      'schedulePairs': schedulePairs.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [number, time, schedulePairs];
}
