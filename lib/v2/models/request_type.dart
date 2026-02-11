import 'package:flutter/material.dart';

enum RequestType {
  group(text: "Группа", query: "group", icon: Icons.group),
  audience(text: "Аудитория", query: "aud", icon: Icons.meeting_room),
  teacher(text: "Преподаватель", query: "teacher", icon: Icons.person);

  final String text;
  final String query;
  final IconData icon;
  const RequestType(
      {required this.text, required this.query, required this.icon});
}
