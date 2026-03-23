import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:usue_schedule/features/schedule/models/schedule_view_type.dart';

class ScheduleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ScheduleViewType viewType;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final VoidCallback navigatePrevious;
  final VoidCallback navigateNext;
  final Function(ScheduleViewType viewType) onViewTypeChanged;
  final VoidCallback showCalendar;

  ScheduleHeaderDelegate({
    required this.viewType,
    required this.rangeStart,
    required this.rangeEnd,
    required this.navigatePrevious,
    required this.navigateNext,
    required this.onViewTypeChanged,
    required this.showCalendar,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isCustom = viewType == ScheduleViewType.custom;
    final isDayView = viewType == ScheduleViewType.day;

    String titleText;
    if (isDayView) {
      titleText = DateFormat('dd MMMM yyyy', 'ru').format(rangeStart);
    } else if (viewType == ScheduleViewType.week ||
        viewType == ScheduleViewType.month) {
      titleText =
          '${DateFormat('dd', 'ru').format(rangeStart)} - ${DateFormat('dd MMMM yyyy', 'ru').format(rangeEnd)}';
    } else {
      titleText =
          '${DateFormat('dd MMM yyyy', 'ru').format(rangeStart)} - ${DateFormat('dd MMM yyyy', 'ru').format(rangeEnd)}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          // Скрываем навигацию для кастомного диапазона
          if (!isCustom)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: navigatePrevious,
              tooltip: isDayView ? 'Предыдущий день' : 'Предыдущая неделя',
            ),
          Expanded(
            child: InkWell(
              onTap: showCalendar,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!isCustom)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: navigateNext,
              tooltip: isDayView ? 'Следующий день' : 'Следующая неделя',
            ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ScheduleViewType>(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                borderRadius: BorderRadius.circular(6),
                alignment: AlignmentDirectional.center,
                value: viewType,
                icon: const SizedBox.shrink(),
                isDense: true,
                dropdownColor: Theme.of(context).canvasColor,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                items: ScheduleViewType.values
                    .map((viewType) => DropdownMenuItem(
                          value: viewType,
                          child: Text(viewType.text),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onViewTypeChanged(value);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => 58;

  @override
  double get minExtent => 58;

  @override
  bool shouldRebuild(covariant ScheduleHeaderDelegate oldDelegate) {
    return viewType != oldDelegate.viewType ||
        rangeStart != oldDelegate.rangeStart ||
        rangeEnd != oldDelegate.rangeEnd;
  }
}
