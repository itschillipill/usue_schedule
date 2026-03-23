import 'package:flutter/material.dart';
import 'package:usue_schedule/core/utils/date_utils.dart';
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
  final Widget buildEmptyState;

  const CustomRangeView({
    super.key,
    required this.data,
    required this.rangeStart,
    required this.rangeEnd,
    required this.groupColors,
    required this.buildEmptyState,
  });

  @override
  Widget build(BuildContext context) {
    final daysWithPairs = data.schedules
        .where((day) => day.hasPairs)
        .map((day) => (
              day: day,
              date: DateTimeUtils.parseDate(day.date)!,
            ))
        .toList();

    if (daysWithPairs.isEmpty) return buildEmptyState;

    final todayDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final List<({DaySchedule day, DateTime date})> previousDays = [];
    final List<({DaySchedule day, DateTime date})> currentFutureDays = [];

    for (final item in daysWithPairs) {
      final dayDateOnly = DateTime(
        item.date.year,
        item.date.month,
        item.date.day,
      );

      if (dayDateOnly.isBefore(todayDate)) {
        previousDays.add(item);
      } else {
        currentFutureDays.add(item);
      }
    }

    previousDays.sort((a, b) => a.date.compareTo(b.date));
    currentFutureDays.sort((a, b) => a.date.compareTo(b.date));

    final hasFutureDays = currentFutureDays.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CustomRangeHeader(
            pairs: daysWithPairs.length,
            startDate: rangeStart,
            endDate: rangeEnd,
          ),
        ),
        if (previousDays.isNotEmpty && hasFutureDays)
          SliverToBoxAdapter(
            child: _PreviousDaysSection(
              days: previousDays,
              groupColors: groupColors,
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item =
                  (hasFutureDays ? currentFutureDays : previousDays)[index];
              final isToday = item.date.isAtSameMomentAs(todayDate);
              return _LessonCard(
                daySchedule: item.day,
                date: item.date,
                groupColors: groupColors,
                isToday: isToday,
              );
            },
            childCount:
                (hasFutureDays ? currentFutureDays : previousDays).length,
          ),
        ),
      ],
    );
  }
}

class _PreviousDaysSection extends StatelessWidget {
  final List<({DaySchedule day, DateTime date})> days;
  final Map<String, Color> groupColors;

  const _PreviousDaysSection({
    required this.days,
    required this.groupColors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),
        leading: const Icon(
          Icons.history,
          size: 20,
        ),
        title: Row(
          spacing: 5,
          children: [
            const Text(
              'Предыдущие дни',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${days.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        children: days.map((item) {
          return _LessonCard(
            daySchedule: item.day,
            date: item.date,
            groupColors: groupColors,
            isPrevious: true,
          );
        }).toList(),
      ),
    );
  }
}

// Виджет карточки дня
class _LessonCard extends StatelessWidget {
  final DaySchedule daySchedule;
  final DateTime date;
  final Map<String, Color> groupColors;
  final bool isToday;
  final bool isPrevious;

  const _LessonCard({
    required this.daySchedule,
    required this.date,
    required this.groupColors,
    this.isToday = false,
    this.isPrevious = false,
  });

  @override
  Widget build(BuildContext context) {
    // Для предыдущих дней делаем немного приглушенными
    final opacity = isPrevious ? 0.7 : 1.0;

    // Определяем, должен ли быть расширен по умолчанию
    final shouldBeExpanded = !isPrevious && (isToday || daySchedule.hasPairs);

    return ExpansionTile(
      initiallyExpanded: shouldBeExpanded,
      tilePadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
      ),
      visualDensity: VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.minimumDensity),
      title: Opacity(
        opacity: opacity,
        child: DayHeader(
          day: daySchedule,
          date: date,
        ),
      ),
      children: daySchedule.nonEmptyPairs
          .map(
            (pair) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Opacity(
                opacity: opacity,
                child: PairCard(
                  pair: pair,
                  groupColors: groupColors,
                  date: date,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class PairCard extends StatelessWidget {
  final Pair pair;
  final DateTime date;
  final Map<String, Color> groupColors;

  const PairCard({
    super.key,
    required this.pair,
    required this.date,
    required this.groupColors,
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
        color: isCurrent
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
            : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.1),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: isCurrent
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
                    '${pair.number} пара',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : theme.hintColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pair.pairTime.split('-')[0].trim(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    pair.pairTime.split('-')[1].trim(),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 8),
                    Icon(Icons.access_time_filled,
                        size: 14, color: theme.colorScheme.primary),
                  ]
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: displayItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final List<SchedulePair> group = entry.value;
                  final isLast = index == displayItems.length - 1;

                  final first = group.first;
                  final hasTitle = index == 0 ||
                      first.subject.trim() !=
                          displayItems[index - 1].first.subject.trim();
                  return _ScheduleItem(
                    first: first,
                    hasTitle: hasTitle,
                    group: group,
                    isLast: isLast,
                    groupColors: groupColors,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final SchedulePair first;
  final List<SchedulePair> group;
  final bool isLast;
  final bool hasTitle;
  final Map<String, Color> groupColors;
  const _ScheduleItem(
      {required this.first,
      required this.group,
      required this.isLast,
      required this.hasTitle,
      required this.groupColors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
      ),
      child: Column(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTitle)
                Text(
                  first.subject.trim(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              if (group.hasMultipleGroups)
                Wrap(
                    spacing: 2,
                    children: group.groups.map(_buildSingleGroupChip).toList()),
            ],
          ),
          Row(
            spacing: 2,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  Text(
                    group.audience,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Text(
                '•',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: Text(
                  softWrap: true,
                  group.teachers.join(','),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
                ),
              ),
              if (group.hasMultipleGroups) LabelGroup(pairs: group.length)
            ],
          ),
          Wrap(
            spacing: 2,
            children: [
              if (!group.hasMultipleGroups)
                _buildSingleGroupChip(first.cleanGroup),
              if (group.subgroups.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_tree_outlined,
                        size: 12,
                        color: Colors.purple,
                      ),
                      Text(
                        'Подгр. ${group.subgroups.join(', ')}',
                        style: const TextStyle(
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
    );
  }

  Widget _buildSingleGroupChip(String group) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (groupColors[group] ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        group,
        style: TextStyle(
          fontSize: 12,
          color: groupColors[group] ?? Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
