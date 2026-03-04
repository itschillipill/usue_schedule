import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:usue_schedule/presentation/widgets/border_box.dart';
import '../../models/pair.dart';
import '../../models/pair_time.dart';
import '../../models/schedule_response.dart';

import '../../models/day_schedule.dart';
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

    return Column(
      spacing: 10,
      children: [
        DayHeader(day: daySchedule, date: selectedDate),
        ...daySchedule.nonEmptyPairs.map(
          (pair) => _TimelineLessonCard(
            pair: pair,
            groupColors: groupColors,
            dateTime: selectedDate,
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
      child: Column(
        children: [
          // Временная метка
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (PairTime.defaultPairTimes[pair.number] ?? pair.time)
                        .toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Пара ${pair.number}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.orange.shade100,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.orange.shade800),
                        const SizedBox(width: 4),
                        Text(
                          'Сейчас',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
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
