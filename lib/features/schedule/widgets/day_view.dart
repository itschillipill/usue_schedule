import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:usue_schedule/shared/widgets/border_box.dart';
import '../models/pair.dart';
import '../models/schedule_response.dart';

import '../models/day_schedule.dart';
import 'day_header.dart';
import 'schedule_item.dart';

class DayView extends StatelessWidget {
  final ScheduleResponse data;
  final DateTime selectedDate;
  final Map<String, Color> groupColors;
  final Widget buildEmptyState;

  const DayView(
      {super.key,
      required this.data,
      required this.selectedDate,
      required this.groupColors,
      required this.buildEmptyState});

  @override
  Widget build(BuildContext context) {
    final selectedDateStr = DateFormat('dd.MM.yyyy').format(selectedDate);
    final daySchedule = data.schedules.firstWhere(
      (day) => day.date == selectedDateStr,
      orElse: () => DaySchedule(
        date: selectedDateStr,
        weekDay: DateFormat('EEEE').format(selectedDate),
        pairs: [],
      ),
    );

    if (!daySchedule.hasPairs) return buildEmptyState;
    final nonEmptyPairs = daySchedule.nonEmptyPairs.toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: DayHeader(day: daySchedule, date: selectedDate)),
        SliverPadding(
          padding: const EdgeInsets.only(top: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final pair = nonEmptyPairs[index];
                return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TimelineLessonCard(
                        pair: pair,
                        groupColors: groupColors,
                        dateTime: selectedDate));
              },
              childCount: nonEmptyPairs.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineLessonCard extends StatelessWidget {
  final Pair pair;
  final Map<String, Color> groupColors;
  final DateTime dateTime;

  const _TimelineLessonCard(
      {required this.pair, required this.groupColors, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    bool isCurrent = pair.isCurrentPair(dateTime);
    return BorderBox(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      borderColor: isCurrent ? Theme.of(context).colorScheme.outline : null,
      child: Column(
        children: [
          // Временная метка
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Пара ${pair.number}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Text(
                    pair.pairTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2,
                      children: [
                        Icon(Icons.access_time,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary),
                        Text(
                          'Сейчас',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          ScheduleItem(
            groupColors: groupColors,
            pairs: pair.schedulePairs,
          )
        ],
      ),
    );
  }
}
