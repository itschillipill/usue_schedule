import 'package:equatable/equatable.dart';
import 'package:usue_schedule/core/utils/date_utils.dart';

import 'pair.dart';

class DaySchedule extends Equatable {
  final DateTime date;
  final String weekDay;
  final List<Pair> pairs;

  const DaySchedule({
    required this.date,
    required this.weekDay,
    required this.pairs,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      date: DateTimeUtils.parseDate(json['date'] as String? ?? '') ??
          DateTime.now(),
      weekDay: json['weekDay'] as String? ?? '',
      pairs: (json['pairs'] as List<dynamic>?)
              ?.map((e) => Pair.fromJson(e))
              .toList() ??
          [],
    );
  }

  DaySchedule empty() =>
      DaySchedule(date: date, weekDay: weekDay, pairs: const []);

  Iterable<Pair> get nonEmptyPairs =>
      pairs.where((p) => p.schedulePairs.isNotEmpty);

  bool get hasPairs => nonEmptyPairs.isNotEmpty;

  Iterable<String> getAllGroups() =>
      pairs.expand((pair) => pair.getAllGroups());

  Iterable<String> getAllTeachers() =>
      pairs.expand((pair) => pair.getAllTeachers());

  Iterable<String> getAllAudiences() =>
      pairs.expand((pair) => pair.getAllAudiences());

  DaySchedule filterByGroup(String groupName) {
    final filteredPairs =
        pairs.map((pair) => pair.filterByGroup(groupName)).toList();
    return DaySchedule(
      date: date,
      weekDay: weekDay,
      pairs: filteredPairs,
    );
  }

  DaySchedule filterByTeacher(String teacherName) {
    final filteredPairs =
        pairs.map((pair) => pair.filterByTeacher(teacherName)).toList();
    return DaySchedule(
      date: date,
      weekDay: weekDay,
      pairs: filteredPairs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': DateTimeUtils.formatDate(date, showWeekday: false),
      'weekDay': weekDay,
      'pairs': nonEmptyPairs.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [date, weekDay, pairs];
}
