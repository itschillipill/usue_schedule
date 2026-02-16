import 'package:flutter/material.dart' show Icons, IconData;

enum ExportFormat {
  ics(Icons.calendar_today, 'ICS (Календарь)',
      'Импорт в Google Calendar, Apple Calendar, Outlook'),
  excel(Icons.table_chart, 'Excel', 'Редактирование и анализ данных'),
  pdf(Icons.picture_as_pdf, 'PDF', 'Печать и общий доступ');

  final IconData icon;
  final String label;
  final String description;

  const ExportFormat(this.icon, this.label, this.description);
}
