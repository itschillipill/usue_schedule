import 'package:material_ui/material_ui.dart';

import 'session_logger.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({
    super.key,
  });

  static Route<T> route<T>() =>
      MaterialPageRoute(builder: (context) => LogsScreen());

  @override
  State<LogsScreen> createState() => _LogsState();
}

class _LogsState extends State<LogsScreen> {
  List<LogEntry> _logs = [];
  @override
  void initState() {
    super.initState();
    _logs = SessionLogger.instance.getLogs();
  }

  Future<void> _showFullLog(LogEntry log) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Вспомогательная функция для цвета плашки уровня лога
    Color getLevelColor(int level) {
      switch (level) {
        case 3:
          return colorScheme.error;
        case 2:
          return Colors.orange;
        case 1:
          return colorScheme.primary;
        default:
          return colorScheme.outline;
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Индикатор свайпа (Drag Handle)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Заголовок: Уровень, Категория и Время
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: getLevelColor(log.level.index)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          log.level.name.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: getLevelColor(log.level.index),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          log.category,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${log.timestamp.hour.toString().padLeft(2, '0')}:'
                        '${log.timestamp.minute.toString().padLeft(2, '0')}:'
                        '${log.timestamp.second.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Основное содержимое с возможностью прокрутки
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // Сообщение
                        Text(
                          'Сообщение:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SelectableText(
                            log.message,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),

                        // Ошибка (если есть)
                        if (log.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Ошибка:',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SelectableText(
                              log.error.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],

                        // Стек трейс (если есть)
                        if (log.stackTrace != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'StackTrace:',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SelectableText(
                              log.stackTrace.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],

                        // Дополнительные данные (Extra, если есть)
                        if (log.extra != null && log.extra!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Extra:',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SelectableText(
                              log.extra.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Logs"),
        ),
        body: ListView.builder(
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            return ListTile(
              title: Text(log.message),
              onTap: () => _showFullLog(log),
            );
          },
        ),
      );
}
