import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class ScheduleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isDayView;
  final DateTime selectedDate;
  final List<DateTime> selectedWeek;
  final VoidCallback navigatePrevious;
  final VoidCallback navigateNext;
  final VoidCallback toggleView;
  final VoidCallback showCalendar;

  ScheduleHeaderDelegate({
    required this.isDayView,
    required this.selectedDate,
    required this.selectedWeek,
    required this.navigatePrevious,
    required this.navigateNext,
    required this.toggleView,
    required this.showCalendar,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
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
                  spacing: 6,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                    ),
                    Text(
                      isDayView
                          ? DateFormat('dd MMMM yyyy', "ru")
                              .format(selectedDate)
                          : '${DateFormat('dd', "ru").format(selectedWeek.first)} - ${DateFormat('dd MMMM yyyy', "ru").format(selectedWeek.last)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: navigateNext,
            tooltip: isDayView ? 'Следующий день' : 'Следующая неделя',
          ), DecoratedBox(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.grey[200]!)
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: toggleView,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color:  Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
             isDayView? 'День':'Неделя',
            style: TextStyle(
              fontWeight:FontWeight.w600,
              color:Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    ],
  ),
)
        ],
      )
    );
  }

  @override
  double get maxExtent => 58;

  @override
  double get minExtent => 58;

  @override
  bool shouldRebuild(covariant ScheduleHeaderDelegate oldDelegate) {
    return isDayView != oldDelegate.isDayView ||
        selectedDate != oldDelegate.selectedDate;
  }
}