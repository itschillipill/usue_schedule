import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usue_schedule/models/schedule_model.dart';
import 'package:usue_schedule/presentation/widgets/border_box.dart';
import 'package:usue_schedule/presentation/widgets/custom_list_tile.dart';
import 'package:usue_schedule/services/file_service.dart';
import 'package:usue_schedule/services/message_service.dart';
import '../models/export_format.dart';
import '../models/schedule_response.dart';

class ExportScheduleScreen extends StatefulWidget {
  static Route route(
    ScheduleModel params,
    Future<ScheduleResponse> Function({
      required DateTime startDate,
      required DateTime endDate,
      required ScheduleModel scheduleModel,
    }) getResponse,
  ) =>
      MaterialPageRoute(
        builder: (_) =>
            ExportScheduleScreen(params: params, getResponse: getResponse),
      );

  const ExportScheduleScreen({
    super.key,
    required this.params,
    required this.getResponse,
  });

  final ScheduleModel params;
  final Future<ScheduleResponse> Function({
    required DateTime startDate,
    required DateTime endDate,
    required ScheduleModel scheduleModel,
  }) getResponse;

  @override
  State<ExportScheduleScreen> createState() => _ExportScheduleScreenState();
}

class _ExportScheduleScreenState extends State<ExportScheduleScreen> {
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now().add(const Duration(days: 6));
  var _selectedFormat = ExportFormat.ics;
  var shareAfterSavig = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Экспорт расписания'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                CustomListTile(
                  mainColor: widget.params.requestType.color,
                  title: widget.params.queryValue,
                  subTitle: widget.params.requestType.text,
                  leadingIcon: widget.params.requestType.icon,
                  cardPadding: EdgeInsets.zero,
                  border: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                _DateRangeSelector(
                  startDate: _startDate,
                  endDate: _endDate,
                  onStartDateChanged: (date) => setState(() {
                    _startDate = date;
                    if (_endDate.isBefore(_startDate)) _endDate = _startDate;
                  }),
                  onEndDateChanged: (date) => setState(() {
                    _endDate = date;
                    if (_startDate.isAfter(_endDate)) _startDate = _endDate;
                  }),
                  onPresetSelected: (days) => setState(
                      () => _endDate = _startDate.add(Duration(days: days))),
                ),
                _FormatSelector(
                  selectedFormat: _selectedFormat,
                  onFormatChanged: (format) =>
                      setState(() => _selectedFormat = format),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.share),
                  title: const Text('Поделиться после экспорта'),
                  value: shareAfterSavig,
                  onChanged: (v) => setState(() => shareAfterSavig = v),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _exportSchedule(),
                    icon: const Icon(Icons.download),
                    label: const Text('Экспортировать расписание'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportSchedule() async {
    if (_selectedFormat != ExportFormat.ics) {
      MessageServise.showSnackBar(
          'Еще не реализован экспорт в формат ${_selectedFormat.label}..');
      return;
    }

    if (_startDate.isAfter(_endDate)) {
      MessageServise.showErrorSnack(
          'Дата начала не может быть позже даты окончания');
      return;
    }

    await MessageServise.showLoading<bool>(
      message: 'Экспорт расписания...',
      onSuccess: (result) {
        if (result) {
          MessageServise.showSuccessSnack(
              'Расписание успешно экспортировано в формат ${_selectedFormat.label}\nФайл находится в папке "Загрузки"');
        }
      },
      onError: (e, st) {
        MessageServise.showErrorSnack('Ошибка при экспорте',
            error: e, stackTrace: st);
      },
      fn: () async {
        final response = await widget.getResponse(
          startDate: _startDate,
          endDate: _endDate,
          scheduleModel: widget.params,
        );

        final filtered = ScheduleResponse(
          schedules: response.schedules
              .where((s) => s.pairs.any((p) => p.schedulePairs.isNotEmpty))
              .toList(),
        );

        if (filtered.schedules.isEmpty) {
          MessageServise.showSnackBar('На этот период расписание не найдено');
          return false;
        }

        await FileService.saveSchedule(
          dateRange: DateTimeRange(start: _startDate, end: _endDate),
          schedule: filtered,
          format: _selectedFormat,
          queryValue: widget.params.queryValue,
          shareAfterSave: shareAfterSavig,
        );
        return true;
      },
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onPresetSelected,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<int> onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMMM yyyy', 'ru');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text('Период экспорта',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Row(
          spacing: 10,
          children: [
            Expanded(
                child: _RangeCard(
              label: 'Начало',
              date: dateFormat.format(startDate),
              onTap: () => _selectDate(context, true),
            )),
            Expanded(
                child: _RangeCard(
              label: 'Конец',
              date: dateFormat.format(endDate),
              onTap: () => _selectDate(context, false),
            )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [7, 29, 90]
              .map((days) => TextButton(
                    onPressed: () => onPresetSelected(days),
                    child: Text(days == 7
                        ? 'Неделя'
                        : days == 29
                            ? 'Месяц'
                            : '3 Месяца'),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ru'),
    );
    if (selected != null) {
      isStart ? onStartDateChanged(selected) : onEndDateChanged(selected);
    }
  }
}

class _RangeCard extends StatelessWidget {
  const _RangeCard(
      {required this.label, required this.date, required this.onTap});

  final String label;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomListTile(
      mainColor: theme.colorScheme.primary,
      title: date,
      subTitle: label,
      onTap: onTap,
      cardPadding: EdgeInsets.zero,
      border:
          BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector(
      {required this.selectedFormat, required this.onFormatChanged});

  final ExportFormat selectedFormat;
  final ValueChanged<ExportFormat> onFormatChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text('Формат экспорта',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ExportFormat.values.map((format) {
            final isSelected = selectedFormat == format;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [Icon(format.icon, size: 16), Text(format.label)],
              ),
              selected: isSelected,
              onSelected: (_) => onFormatChanged(format),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            );
          }).toList(),
        ),
        BorderBox(
          child: AnimatedSize(
            duration: Durations.short2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _getInstructionsForFormat(selectedFormat),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _getInstructionsForFormat(ExportFormat format) {
    switch (format) {
      case ExportFormat.ics:
        return [
          Text('📅 ICS (iCalendar)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
              '✓ Подходит для: Google Calendar, Apple Calendar, Outlook'),
          const Text('✓ Как использовать:'),
          const Text('  • Для Google Календаря — ТОЛЬКО через компьютер!'),
          const Text('  • Зайдите в веб-версию Google Календаря'),
          const Text('  • Настройки → Импорт → выберите скачанный файл'),
          const Text(
              '  • Для других календарей — импортируйте файл как угодно'),
        ];

      case ExportFormat.excel:
        return [
          Text('📊 Excel', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('✓ Для редактирования и анализа данных'),
          const Text('✓ Открывается в Microsoft Excel, Google Таблицах'),
          const Text('✓ Можно сортировать, фильтровать, добавлять заметки'),
          const Text('✓ Удобно для печати в структурированном виде'),
        ];

      case ExportFormat.pdf:
        return [
          Text('📄 PDF', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('✓ Для печати и отправки'),
          const Text('✓ Сохраняется исходное форматирование'),
          const Text('✓ Удобно делиться с другими'),
          const Text('✓ Можно подписывать и комментировать'),
        ];
    }
  }
}
