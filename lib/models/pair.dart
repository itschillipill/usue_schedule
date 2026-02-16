import 'schedule_pair.dart';

class Pair {
  final int number;
  final String time;
  final bool isCurrentPair;
  final List<SchedulePair> schedulePairs;

  Pair({
    required this.number,
    required this.time,
    required this.isCurrentPair,
    required this.schedulePairs,
  });

  factory Pair.fromJson(Map<String, dynamic> json) {
    return Pair(
      number: json['N'] as int? ?? 1,
      time: json['time'] as String? ?? '',
      isCurrentPair: (json['isCurrentPair'] as int? ?? 0) == 1,
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
      isCurrentPair: isCurrentPair,
      schedulePairs: filtered,
    );
  }

  Pair filterByTeacher(String teacherName) {
    final filtered =
        schedulePairs.where((sp) => sp.teacher.contains(teacherName)).toList();

    return Pair(
      number: number,
      time: time,
      isCurrentPair: isCurrentPair,
      schedulePairs: filtered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'N': number,
      'time': time,
      'isCurrentPair': isCurrentPair ? 1 : 0,
      'schedulePairs': schedulePairs.map((e) => e.toJson()).toList(),
    };
  }
}
