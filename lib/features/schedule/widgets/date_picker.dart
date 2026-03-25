import 'package:flutter/material.dart';

class DatePicker {
  final BuildContext context;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  DatePicker({
    required this.context,
    required this.selectedDate,
    required this.onDateSelected,
  });

  void call() async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year + 1, now.month, now.day);
    final minDate = DateTime(now.year - 1, now.month, now.day);

    DateTime? date = await showModalBottomSheet<DateTime?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  const Expanded(
                    child: Text(
                      'Выберите дату',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, DateTime.now()),
                    child: const Text("Сегодня"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: minDate,
                  lastDate: maxDate,
                  currentDate: now,
                  onDateChanged: (newDate) => Navigator.pop(context, newDate)),
            ],
          ),
        );
      },
    );

    if (date != null) {
      onDateSelected(date);
    }
  }
}
