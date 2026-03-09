import 'package:flutter/material.dart';

class ExportDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const _ExportDialog(),
    );
  }
}

class _ExportDialog extends StatelessWidget {
  const _ExportDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_rounded,
                size: 48,
                color: theme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Экспорт расписания',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Доступна фильтрация расписания',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Options

            _buildOption(
              context,
              icon: Icons.filter_alt,
              title: 'Применить фильтр',
              subtitle: 'Экспортировать только выбранные элементы',
              color: Colors.blue,
              value: true, // Передаем true для выбора с фильтром
            ),

            const SizedBox(height: 12),

            _buildOption(
              context,
              icon: Icons.upload_file,
              title: 'Экспортировать всё',
              subtitle: 'Весь период без фильтрации',
              color: Colors.green,
              value: false, // Передаем false для выбора без фильтра
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

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
  }) {
    return InkWell(
      onTap: () {
        // Закрываем диалог и возвращаем выбранное значение
        Navigator.pop(context, value);
      },
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
