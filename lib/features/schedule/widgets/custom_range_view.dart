import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../controllers/schedule_view_provider.dart';
import '../models/day_schedule.dart';
import '../models/pair.dart';
import '../models/schedule_pair.dart';
import '../models/schedule_type.dart';
import '../presentation/pair_view_screen.dart';
import 'day_header.dart';
import 'custom_view_header.dart';

class CustomRangeView extends StatelessWidget {
  final Iterable<DaySchedule> data;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final Widget buildEmptyState;

  const CustomRangeView({
    super.key,
    required this.data,
    required this.rangeStart,
    required this.rangeEnd,
    required this.buildEmptyState,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    final daysWithPairs =
        data.where((day) => day.hasPairs).toList(growable: false);

    if (daysWithPairs.isEmpty) return buildEmptyState;

    final List<int> previousDays = [];
    final List<int> currentFutureDays = [];

    for (int i = 0; i < daysWithPairs.length; i++) {
      if (daysWithPairs[i].date.isBefore(todayDate)) {
        previousDays.add(i);
      } else {
        currentFutureDays.add(i);
      }
    }

    final hasCurrentDays = currentFutureDays.isNotEmpty;
    final activeDaysList = hasCurrentDays ? currentFutureDays : previousDays;

    final totalPairsCount = daysWithPairs.fold<int>(
      0,
      (sum, item) => sum + item.nonEmptyPairs.length,
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CustomViewHeader(
            days: daysWithPairs.length,
            pairs: totalPairsCount,
            startDate: rangeStart,
            endDate: rangeEnd,
          ),
        ),
        if (previousDays.isNotEmpty && hasCurrentDays)
          SliverToBoxAdapter(
            child: _PreviousDaysSection(
              day: previousDays.map(((e) => daysWithPairs[e])),
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = daysWithPairs[activeDaysList[index]];
              final isToday = item.date.year == todayDate.year &&
                  item.date.month == todayDate.month &&
                  item.date.day == todayDate.day;

              return _LessonCard(
                daySchedule: item,
                isToday: isToday,
              );
            },
            childCount: activeDaysList.length,
          ),
        ),
      ],
    );
  }
}

class _PreviousDaysSection extends StatelessWidget {
  final Iterable<DaySchedule> day;

  const _PreviousDaysSection({
    required this.day,
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
                '${day.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        children: day.map((item) {
          return _LessonCard(
            daySchedule: item,
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
  final bool isToday;
  final bool isPrevious;

  const _LessonCard({
    required this.daySchedule,
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
        child: DayHeader(day: daySchedule),
      ),
      children: daySchedule.nonEmptyPairs
          .map(
            (pair) => Opacity(
              opacity: opacity,
              child: PairCard(
                pair: pair,
                date: daySchedule.date,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class PairCard extends StatelessWidget {
  final Pair pair;
  final DateTime date;

  const PairCard({
    super.key,
    required this.pair,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = pair.isCurrentPair(date);
    final theme = Theme.of(context);

    // Группируем пары по предмету, типу и аудитории
    final groupedPairs = <String, List<SchedulePair>>{};
    for (var sp in pair.schedulePairs) {
      final key = "${sp.subject}|${sp.lessonType}|${sp.audience}";
      groupedPairs.putIfAbsent(key, () => []).add(sp);
    }
    final displayItems = groupedPairs.values.toList();

    // Извлекаем время начала и окончания
    final timeParts = pair.pairTime.split('-');
    final startTime = timeParts.isNotEmpty ? timeParts[0].trim() : '';
    final endTime = timeParts.length > 1 ? timeParts[1].trim() : '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PairViewScreen(pair: pair),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.12)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.15),
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 12, top: 8, bottom: 4, right: 12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${pair.number} пара',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isCurrent
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$startTime – $endTime',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const Spacer(),
                  if (isCurrent) ...[
                    Icon(
                      Icons.access_time_filled,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),

            // Список элементов пары
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(displayItems.length, (index) {
                  final List<SchedulePair> group = displayItems[index];

                  final hasTitle = index == 0 ||
                      group.first.subject.trim() !=
                          displayItems[index - 1].first.subject.trim();
                  return _ScheduleItem(
                    hasTitle: hasTitle,
                    group: group,
                    isLast: index == displayItems.length - 1,
                  );
                }, growable: false)),
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final List<SchedulePair> group;
  final bool isLast;
  final bool hasTitle;

  const _ScheduleItem({
    required this.group,
    required this.isLast,
    required this.hasTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ScheduleViewProvider>();
    final ScheduleType scheduleType = provider.params.scheduleType;

    final bool showTeacher = scheduleType != ScheduleType.teacher;
    final bool showGroup = scheduleType != ScheduleType.group;

    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 6),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTitle)
            Text(
              group.first.subject.trim(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              children: [
                if (group.audience.isNotEmpty) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.meeting_room_outlined,
                        size: 14,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: group.audience,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
                if (group.audience.isNotEmpty && showTeacher)
                  TextSpan(
                    text: ' • ',
                    style: TextStyle(color: theme.hintColor),
                  ),
                if (showTeacher)
                  TextSpan(
                    text: group.teachers.join(', '),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (showGroup || group.subgroups.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (group.hasMultipleGroups)
                  ...group.map(
                    (p) {
                      return _buildChip(
                        text: p.cleanGroup,
                        color: provider.groupColors[group.first.cleanGroup] ??
                            theme.colorScheme.primary,
                      );
                    },
                  )
                else if (showGroup)
                  _buildChip(
                    text: group.first.cleanGroup,
                    color: provider.groupColors[group.first.cleanGroup] ??
                        theme.colorScheme.primary,
                  ),
                if (group.subgroups.isNotEmpty)
                  _buildChip(
                    text: 'Подгр. ${group.subgroups.join(', ')}',
                    color: Colors.purple,
                    icon: Icons.account_tree_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
