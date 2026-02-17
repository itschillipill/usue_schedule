import 'package:flutter/material.dart';
import 'package:usue_schedule/core/theme/app_pallete.dart';

class ScheduleStyles {
  static BoxDecoration linearBackgroundDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          Theme.of(context).colorScheme.surface,
        ],
      ),
    );
  }

  // Цвета для групп (учитывает тему)
  static Color getGroupColor(int index) =>
      AppPallete.groupColors[index % AppPallete.groupColors.length];

  static Color getLessonTypeColor(String type) {
    switch (type) {
      case 'Лекция':
        return Colors.blue;
      case 'Лабораторная':
        return Colors.green;
      case 'Консультация':
        return Colors.orange;
      case 'Экзамен':
        return Colors.purple;
      case 'Зачет':
        return Colors.deepOrange;
      case 'Практика':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  static BoxDecoration lessonTypeDecoration(String type) {
    return BoxDecoration(
      color: getLessonTypeColor(type).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(6),
    );
  }
}
