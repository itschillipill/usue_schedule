import 'package:flutter/material.dart';
import 'package:usue_schedule/widgets/borde_box.dart';

import '../models/day_schedule.dart';

class DayHeader extends StatelessWidget {
  final DaySchedule day;
  final DateTime date;
  final bool? isExpanded;

  const DayHeader({super.key, required this.day, required this.date, this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final dayName = day.weekDay.isNotEmpty ? day.weekDay : date.toString();
    bool isCurrent = day.isCurrentDate;

    return BorderBox(
      padding: const EdgeInsets.all(8),
      color: isCurrent?Theme.of(context).canvasColor:null,
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isCurrent
                    ? Colors.grey[100]
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            child: Text(dayName[0].toUpperCase() + dayName.substring(1),
                style: Theme.of(context).textTheme.titleLarge),
          ),
          if (day.hasPairs)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${day.nonEmptyPairs.length} пар${_getPairsEnding(day.nonEmptyPairs.length)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ),
           if(isExpanded case bool i)Icon(i? Icons.arrow_circle_up_rounded: Icons.arrow_circle_down_rounded)
        ],
      ),
    );
  }
}

String _getPairsEnding(int pairs) {
  final lastDigit = pairs % 10;
  final lastTwoDigits = pairs % 100;

  if (lastTwoDigits >= 11 && lastTwoDigits <= 14) return '';

  if (lastDigit == 1) return 'а';
  if (lastDigit >= 2 && lastDigit <= 4) return 'ы';
  return '';
}
