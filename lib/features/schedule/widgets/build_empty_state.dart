import 'package:flutter/material.dart';

class BuildEmptyState extends StatelessWidget {
  final bool isFiltered;
  final bool isDayView;
  final VoidCallback clearFilters;
  const BuildEmptyState(
      {super.key,
      required this.isFiltered,
      required this.isDayView,
      required this.clearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'Нет занятий для выбранного фильтра' : 'Нет занятий',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDayView
                  ? 'На выбранный день занятий не найдено'
                  : 'На выбранный период занятий не найдено',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (isFiltered)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: clearFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade100,
                    foregroundColor: Colors.amber.shade800,
                  ),
                  child: const Text('Сбросить фильтр'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
