import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../models/pair.dart';
import '../models/schedule_pair.dart';
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
        pairs: const [],
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
                        date: selectedDate));
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
  final DateTime date;

  const _TimelineLessonCard({
    required this.pair,
    required this.groupColors,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = pair.isCurrentPair(date);
    final theme = Theme.of(context);

    final groupedPairs = <String, List<SchedulePair>>{};
    for (var sp in pair.schedulePairs) {
      final key = "${sp.subject}|${sp.lessonType}|${sp.audience}";
      groupedPairs.putIfAbsent(key, () => []).add(sp);
    }
    final displayItems = groupedPairs.values.toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent
            ? Border(
                bottom: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
                top: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
                left: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 6,
                ),
                right: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              )
            : Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.hintColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${pair.number} пара',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            pair.pairTime,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          if (isCurrent) _buildLiveIndicator(theme),
                        ],
                      ),
                    ),
                    Column(
                      children: displayItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final group = entry.value;

                        final hasTitle = index == 0 ||
                            group.first.subject !=
                                displayItems[index - 1].first.subject;
                        return ScheduleItem(
                          pairs: group,
                          groupColors: groupColors,
                          hasTitle: hasTitle,
                          isLast: index == displayItems.length - 1,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_filled,
              size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            'ИДЕТ СЕЙЧАС',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
