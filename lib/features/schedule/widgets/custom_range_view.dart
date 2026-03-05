import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:usue_schedule/shared/widgets/border_box.dart';
import 'package:usue_schedule/features/schedule/widgets/label_group.dart';

import '../models/day_schedule.dart';
import '../models/pair.dart';
import '../models/schedule_pair.dart';
import '../models/schedule_response.dart';
import 'day_header.dart';
import 'custom_range_header.dart';

class CustomRangeView extends StatelessWidget {
  final ScheduleResponse data;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final Map<String, Color> groupColors;
  final String? selectedGroupFilter;
  final Widget buildEmptyState;
  const CustomRangeView(
      {super.key,
      required this.data,
      required this.rangeStart,
      required this.rangeEnd,
      required this.groupColors,
      this.selectedGroupFilter,
      required this.buildEmptyState});

  @override
  Widget build(BuildContext context) {
    final daysWithPairs = data.schedules.where((day) => day.hasPairs).toList();

    if (daysWithPairs.isEmpty) return buildEmptyState;

    return Column(
      spacing: 5,
      children: [
        CustomRangeHeader(
          days: data.schedules,
          startDate: rangeStart,
          endDate: rangeEnd,
        ),
        ...daysWithPairs.map(
          (day) => _LessonCard(
            daySchedule: day,
            date: DateFormat('dd.MM.yyyy').parse(day.date),
            groupColors: groupColors,
            selectedGroup: selectedGroupFilter,
          ),
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
      ),
      title: DayHeader(
        day: daySchedule,
        date: date,
      ),
      children: daySchedule.nonEmptyPairs
          .map(
            (pair) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: _CompactLessonCard(
                pair: pair,
                groupColors: groupColors,
                selectedGroup: selectedGroup,
                dateTime: date,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CompactLessonCard extends StatelessWidget {
  final DateTime dateTime;
  final Pair pair;
  final Map<String, Color> groupColors;
  final String? selectedGroup;

  const _CompactLessonCard(
      {required this.pair,
      required this.groupColors,
      this.selectedGroup,
      required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final schedulePair = pair.schedulePairs.first;
    final isCurrent = pair.isCurrentPair(dateTime);
    return BorderBox(
      color: isCurrent ? Theme.of(context).canvasColor : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5,
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
              if (isCurrent)
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
              if (pair.schedulePairs.hasMultipleGroups)
                LabelGroup(
                  pairs: pair.schedulePairs.length,
                )
            ],
          ),
          Row(
            spacing: 5,
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: groupColors[schedulePair.cleanGroup] ?? Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
                      pair.schedulePairs.teachers.join(", "),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Wrap(
                      spacing: 5,
                      children: [
                        ...pair.schedulePairs.groups
                            .map<Widget>((group) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: groupColors[group]
                                        ?.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    group,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: groupColors[group],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )),
                      ],
                    ),
                    Row(
                      spacing: 2,
                      children: [
                        Icon(Icons.meeting_room, size: 12),
                        Text(
                          schedulePair.audience,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Spacer(),
                        if (pair.schedulePairs.subgroups.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 2,
                              children: [
                                Icon(
                                  Icons.account_tree_outlined,
                                  size: 12,
                                  color: Colors.purple,
                                ),
                                Text(
                                  'Подгр. ${pair.schedulePairs.subgroups.join(', ')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
