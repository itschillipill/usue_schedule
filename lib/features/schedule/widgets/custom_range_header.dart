import 'package:flutter/material.dart';
import 'package:usue_schedule/shared/widgets/border_box.dart';

class CustomRangeHeader extends StatelessWidget {
  final int pairs;
  final DateTime startDate;
  final DateTime endDate;

  const CustomRangeHeader(
      {super.key,
      required this.pairs,
      required this.startDate,
      required this.endDate});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$pairs дней",
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
