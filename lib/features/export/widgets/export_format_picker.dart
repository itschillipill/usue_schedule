import 'package:flutter/material.dart';
import 'package:usue_schedule/features/export/models/export_format.dart';

class ExportFormatPicker {
  static Future<ExportFormat?> show(BuildContext context) {
    return showDialog<ExportFormat>(
      context: context,
      builder: (context) => const _ExportFormatPickerDialog(),
    );
  }
}

class _ExportFormatPickerDialog extends StatelessWidget {
  const _ExportFormatPickerDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Выберите формат',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'В каком формате экспортировать расписание?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Format options
            _buildFormatOption(
              context,
              format: ExportFormat.word,
              icon: Icons.description,
              title: 'Word документ',
              subtitle: 'Формат .doc для редактирования',
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _buildFormatOption(
              context,
              format: ExportFormat.ics,
              icon: Icons.calendar_month,
              title: 'iCalendar',
              subtitle: 'Формат .ics для календаря',
              color: Colors.purple,
            ),

            const SizedBox(height: 8),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(
    BuildContext context, {
    required ExportFormat format,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, format),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                format.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
