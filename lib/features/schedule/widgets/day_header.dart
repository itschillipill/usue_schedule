import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart';
import '../models/day_schedule.dart';

class DayHeader extends StatelessWidget {
  final DaySchedule day;
  final DateTime date;

  const DayHeader({super.key, required this.day, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayName = day.weekDay.isNotEmpty ? day.weekDay : date.toString();
    final isToday = DateTimeUtils.isToday(date);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.1),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isToday
                    ? theme.colorScheme.primary.withValues(alpha: 0.05)
                    : null,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateTimeUtils.getMonthName(date).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          isToday ? theme.colorScheme.primary : theme.hintColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(width: 1),

            // --- ПРАВАЯ ЧАСТЬ (ДЕНЬ НЕДЕЛИ И СЧЕТЧИК) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dayName[0].toUpperCase() + dayName.substring(1),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isToday ? theme.colorScheme.primary : null,
                        ),
                      ),
                    ),
                    if (day.hasPairs)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${day.nonEmptyPairs.length} пар${_getPairsEnding(day.nonEmptyPairs.length)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
