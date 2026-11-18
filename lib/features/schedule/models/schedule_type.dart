import 'package:material_ui/material_ui.dart';

enum ScheduleType {
  group(text: "Группа", query: "group", icon: Icons.group),
  audience(text: "Аудитория", query: "aud", icon: Icons.meeting_room),
  teacher(text: "Преподаватель", query: "teacher", icon: Icons.person);

  final String text;
  final String query;
  final IconData icon;
  const ScheduleType(
      {required this.text, required this.query, required this.icon});

  Color get color => switch (this) {
        ScheduleType.group => Colors.green,
        ScheduleType.audience => Colors.orange,
        ScheduleType.teacher => Colors.blue,
      };

  bool get isGroup => this == ScheduleType.group;
  bool get isAudience => this == ScheduleType.audience;
  bool get isTeacher => this == ScheduleType.teacher;
}
