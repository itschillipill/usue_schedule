import 'package:flutter/material.dart';

class LabelGroup extends StatelessWidget {
  final int pairs;
  const LabelGroup({super.key, required this.pairs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        spacing: 4,
        children: [
          Icon(
            Icons.group,
            size: 12,
            color: Colors.blue,
          ),
          Text(
            '$pairs групп${_getGroupsEnding(pairs)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String _getGroupsEnding(int groups) {
  final lastDigit = groups % 10;
  final lastTwoDigits = groups % 100;

  if (lastTwoDigits >= 11 && lastTwoDigits <= 14) return '';

  if (lastDigit == 1) return 'а';
  if (lastDigit >= 2 && lastDigit <= 4) return 'ы';
  return '';
}
