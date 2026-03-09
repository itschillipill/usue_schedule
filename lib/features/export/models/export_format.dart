import 'dart:ui' show Color;

import 'package:flutter/material.dart' show Icons, IconData, Colors;

enum ExportFormat {
  ics(Icons.calendar_today, 'ICS (Календарь)',
      'Импорт в Google Calendar, Apple Calendar, Outlook', Colors.blue),
  // excel(Icons.table_chart, 'Excel', 'Редактирование и анализ данных',
  //     Colors.green),
  // pdf(Icons.picture_as_pdf, 'PDF', 'Печать и общий доступ', Colors.orange),
  word(Icons.file_copy, 'Word', 'Печать и общий доступ', Colors.red);

  final IconData icon;
  final String label;
  final String description;
  final Color color;

  const ExportFormat(this.icon, this.label, this.description, this.color);
}
