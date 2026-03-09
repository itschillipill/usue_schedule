import 'package:flutter/material.dart';
import 'package:usue_schedule/shared/widgets/border_box.dart';

import '../models/day_schedule.dart';

class CustomRangeHeader extends StatelessWidget {
  final List<DaySchedule> days;
  final DateTime startDate;
  final DateTime endDate;

  const CustomRangeHeader(
      {super.key,
      required this.days,
      required this.startDate,
      required this.endDate});

  @override
  Widget build(BuildContext context) {
    int pairs =
        days.map((day) => day.nonEmptyPairs.length).reduce((a, b) => a + b);
    return BorderBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "На этот прериод:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$pairs пар${_getPairsEnding(pairs)}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _getPairsEnding(int pairs) {
  final lastDigit = pairs % 10;
  final lastTwoDigits = pairs % 100;

  if (lastTwoDigits >= 11 && lastTwoDigits <= 14) return '';

  if (lastDigit == 1) return 'а';
  if (lastDigit >= 2 && lastDigit <= 4) return 'ы';
  return '';
}
