import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePicker {
  final BuildContext context;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  DatePicker(
      {required this.context,
      required this.selectedDate,
      required this.onDateSelected});

  void call() async {
    DateTime? date = await showModalBottomSheet<DateTime?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(12),
          child: Column(
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Expanded(
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
                      child: Text("Сегодня")),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: SfDateRangePicker(
                  initialSelectedDate: selectedDate,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is DateTime) {
                      Navigator.pop(context, args.value);
                    }
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1,
                  ),
                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
