import 'package:flutter/material.dart';

class CustomRangeHeader extends StatelessWidget {
  final int pairs;
  final int days;
  final DateTime startDate;
  final DateTime endDate;

  const CustomRangeHeader({
    super.key,
    required this.pairs,
    required this.days,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                spacing: 5,
                children: [
                  Expanded(
                    child: Text(
                      "Занятий на этот период:",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "$days дн.",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "$pairs пар${_getPairsEnding(pairs)}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPairsEnding(int pairs) {
    final lastDigit = pairs % 10;
    final lastTwoDigits = pairs % 100;

    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) return '';

    if (lastDigit == 1) return 'а';
    if (lastDigit >= 2 && lastDigit <= 4) return 'ы';
    return '';
  }
}
