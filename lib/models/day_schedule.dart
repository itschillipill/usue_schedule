import 'pair.dart';

class DaySchedule {
  final String date;
  final String weekDay;
  final bool isCurrentDate;
  final List<Pair> pairs;

  DaySchedule({
    required this.date,
    required this.weekDay,
    required this.isCurrentDate,
    required this.pairs,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      date: json['date'] as String? ?? '',
      weekDay: json['weekDay'] as String? ?? '',
      isCurrentDate: (json['isCurrentDate'] as int? ?? 0) == 1,
      pairs: (json['pairs'] as List<dynamic>?)
              ?.map((e) => Pair.fromJson(e))
              .toList() ??
          [],
    );
  }

  List<Pair> get nonEmptyPairs =>
      pairs.where((p) => p.schedulePairs.isNotEmpty).toList();

  bool get hasPairs => nonEmptyPairs.isNotEmpty;

  List<String> getAllGroups() {
    final groups = <String>{};
    for (var pair in pairs) {
      for (var group in pair.getAllGroups()) {
        groups.add(group);
      }
    }
    return groups.toList();
  }

  List<String> getAllTeachers() {
    final teachers = <String>{};
    for (var pair in pairs) {
      for (var teacher in pair.getAllTeachers()) {
        teachers.add(teacher);
      }
    }
    return teachers.toList();
  }

  List<String> getAllAudiences() {
    final audiences = <String>{};
    for (var pair in pairs) {
      for (var audience in pair.getAllAudiences()) {
        audiences.add(audience);
      }
    }
    return audiences.toList();
  }

  DaySchedule filterByGroup(String groupName) {
    final filteredPairs =
        pairs.map((pair) => pair.filterByGroup(groupName)).toList();
    return DaySchedule(
      date: date,
      weekDay: weekDay,
      isCurrentDate: isCurrentDate,
      pairs: filteredPairs,
    );
  }

  DaySchedule filterByTeacher(String teacherName) {
    final filteredPairs =
        pairs.map((pair) => pair.filterByTeacher(teacherName)).toList();
    return DaySchedule(
      date: date,
      weekDay: weekDay,
      isCurrentDate: isCurrentDate,
      pairs: filteredPairs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weekDay': weekDay,
      'isCurrentDate': isCurrentDate ? 1 : 0,
      'pairs': pairs.map((e) => e.toJson()).toList(),
    };
  }
}
