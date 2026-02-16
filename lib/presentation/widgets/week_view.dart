import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:usue_schedule/presentation/widgets/borde_box.dart';
import 'package:usue_schedule/presentation/widgets/label_group.dart';

import '../../core/utils/date_utils.dart';
import '../../models/day_schedule.dart';
import '../../models/pair.dart';
import '../../models/schedule_response.dart';
import 'day_header.dart';
import 'week_header.dart';

class WeekView extends StatelessWidget {
  final ScheduleResponse data;
  final List<DateTime> selectedWeek;
  final Map<String, Color> groupColors;
  final String? selectedGroupFilter;
  final Widget buildEmptyState;
  const WeekView(
      {super.key,
      required this.data,
      required this.selectedWeek,
      required this.groupColors,
      this.selectedGroupFilter,
      required this.buildEmptyState});

  @override
  Widget build(BuildContext context) {
    final scheduleMap = {for (var day in data.schedules) day.date: day};
    if (!scheduleMap.values.any((d) => d.hasPairs)) return buildEmptyState;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        WeekHeader(
          days: data.schedules,
          startDate: selectedWeek.first,
          endDate: selectedWeek.last,
        ),
        const SizedBox(height: 12),
        ...selectedWeek.map((date) {
          final dateStr = DateFormat('dd.MM.yyyy').format(date);
          final daySchedule = scheduleMap[dateStr] ??
              DaySchedule(
                date: dateStr,
                weekDay: DateFormat('EEEE').format(date),
                isCurrentDate: DateTimeUtils.isToday(date),
                pairs: [],
              );
          if (!daySchedule.hasPairs) return SizedBox.shrink();
          return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LessonCard(
                daySchedule: daySchedule,
                date: date,
                groupColors: groupColors,
                selectedGroup: selectedGroupFilter,
              ));
        })
      ]),
    );
  }
}

class _LessonCard extends StatefulWidget {
  final DaySchedule daySchedule;
  final DateTime date;
  final Map<String, Color> groupColors;
  final String? selectedGroup;

  const _LessonCard({
    required this.daySchedule,
    required this.date,
    required this.groupColors,
    this.selectedGroup,
  });
  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  bool isExpanded = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: DayHeader(
              day: widget.daySchedule,
              date: widget.date,
              isExpanded: isExpanded,
            )),
        AnimatedSize(
          duration: Durations.short4,
          curve: Curves.linear,
          child: !isExpanded
              ? SizedBox.shrink()
              : Column(children: [
                  ...widget.daySchedule.nonEmptyPairs.map(
                    (pair) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CompactLessonCard(
                        pair: pair,
                        groupColors: widget.groupColors,
                        selectedGroup: widget.selectedGroup,
                      ),
                    ),
                  ),
                ]),
        )
      ],
    );
  }
}

class _CompactLessonCard extends StatelessWidget {
  final Pair pair;
  final Map<String, Color> groupColors;
  final String? selectedGroup;

  const _CompactLessonCard({
    required this.pair,
    required this.groupColors,
    this.selectedGroup,
  });

  @override
  Widget build(BuildContext context) {
    final schedulePair = pair.schedulePairs.first;
    return BorderBox(
      color: pair.isCurrentPair ? Theme.of(context).canvasColor : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  pair.time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (pair.isCurrentPair)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Сейчас',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              const Spacer(),
              if (pair.schedulePairs.length > 1)
                LabelGroup(
                  pairs: pair.schedulePairs.length,
                )
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: groupColors[schedulePair.cleanGroup] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        schedulePair.subject,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        schedulePair.teacher,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Wrap(
                        spacing: 5,
                        children: [
                          ...pair.schedulePairs.map(
                            (sp) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: groupColors[sp.cleanGroup]
                                    ?.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                sp.cleanGroup,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: groupColors[sp.cleanGroup],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            spacing: 2,
                            children: [
                              Icon(Icons.meeting_room, size: 12),
                              Text(
                                schedulePair.audience,
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
