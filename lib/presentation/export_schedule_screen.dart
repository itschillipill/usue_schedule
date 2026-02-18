import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usue_schedule/models/schedule_model.dart';
import 'package:usue_schedule/services/file_service.dart';
import 'package:usue_schedule/services/message_service.dart';
import 'package:usue_schedule/presentation/widgets/borde_box.dart';

import '../models/export_format.dart';
import '../models/request_type.dart';
import '../models/schedule_response.dart';

class ExportScheduleScreen extends StatefulWidget {
  static Route route(
      ScheduleModel params,
      Future<ScheduleResponse> Function(
              {required DateTime startDate,
              required DateTime endDate,
              required RequestType requestType,
              required String queryValue})
          getResponse) {
    return MaterialPageRoute(
      builder: (_) =>
          ExportScheduleScreen(params: params, getResponse: getResponse),
    );
  }

  final ScheduleModel params;
  final Future<ScheduleResponse> Function(
      {required DateTime startDate,
      required DateTime endDate,
      required RequestType requestType,
      required String queryValue}) getResponse;

  const ExportScheduleScreen(
      {super.key, required this.params, required this.getResponse});

  @override
  State<ExportScheduleScreen> createState() => _ExportScheduleScreenState();
}

class _ExportScheduleScreenState extends State<ExportScheduleScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 6));
  ExportFormat _selectedFormat = ExportFormat.ics;
  bool shareAfterSavig = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Экспорт расписания'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              _buildScheduleInfo(theme),
              _buildDateRangeSelector(theme),
              _buildFormatSelector(theme),
              const Spacer(),
              SwitchListTile(
                  secondary: Icon(Icons.share),
                  title: Text("Поделиться после экспорта"),
                  value: shareAfterSavig,
                  onChanged: (v) => setState(() => shareAfterSavig = v)),
              _buildExportButton(),
            ],
          ),
        ),
      ),
    );
  }

// Helpers

  Widget _buildScheduleInfo(ThemeData theme) {
    return BorderBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Row(
            spacing: 5,
            children: [
              Icon(widget.params.requestType.icon,
                  color: theme.colorScheme.primary),
              Text(widget.params.requestType.text,
                  style: theme.textTheme.titleMedium),
            ],
          ),
          Text(
            widget.params.queryValue,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(ThemeData theme) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'ru');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          'Период экспорта',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
                child: _buildRangeCard(theme, "Начало", () => _selectDate(true),
                    dateFormat.format(_startDate))),
            Expanded(
                child: _buildRangeCard(theme, "Конец", () => _selectDate(false),
                    dateFormat.format(_endDate))),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _setDateRange(8),
              child: Text('Неделя'),
            ),
            TextButton(
              onPressed: () => _setDateRange(29),
              child: Text('Месяц'),
            ),
            TextButton(
              onPressed: () => _setDateRange(90),
              child: Text('3 Месяца'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          'Формат экспорта',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ExportFormat.values.map((format) {
            final isSelected = _selectedFormat == format;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Icon(format.icon, size: 16),
                  Text(format.label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFormat = format;
                });
              },
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        Text(
          _selectedFormat.description,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _exportSchedule(context),
        icon: const Icon(Icons.download),
        label: const Text('Экспортировать расписание'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      locale: const Locale('ru'),
    );

    if (selected != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selected;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = selected;
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _setDateRange(int days) {
    setState(() {
      _endDate = _startDate.add(Duration(days: days));
    });
  }

  void _showHelpDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Справка по экспорту'),
          content: const Text(
            '• ICS: Импорт в Google Calendar, Apple Calendar, Outlook\n'
            '• Excel: Редактирование и анализ в таблицах\n'
            '• PDF: Печать и общий доступ\n\n'
            'Выберите период и настройте параметры экспорта.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );

  Future<void> _exportSchedule(BuildContext context) async =>
      await MessageServise.showLoading<bool>(
        message: 'Экспорт расписания...',
        onSuccess: (success) {
          if (success == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Расписание успешно экспортировано в формат ${_selectedFormat.label}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onError: (e, stackTrace) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка при экспорте: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        fn: () async {
          if (_selectedFormat != ExportFormat.ics) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Durations.extralong1,
                  content: Text(
                      'Еще не реализован экспорт в формат ${_selectedFormat.label}..'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
            return false;
          }

          if (_startDate.isAfter(_endDate)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Дата начала не может быть позже даты окончания'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
            return false;
          }

          final response = await widget.getResponse(
            startDate: _startDate,
            endDate: _endDate,
            requestType: widget.params.requestType,
            queryValue: widget.params.queryValue,
          );

          final filteredResponse = ScheduleResponse(
            schedules: response.schedules
                .where((s) => s.pairs.any((p) => p.schedulePairs.isNotEmpty))
                .toList(),
          );

          if (filteredResponse.schedules.isNotEmpty &&
              filteredResponse.schedules
                  .any((s) => s.pairs.any((p) => p.schedulePairs.isNotEmpty))) {
            await FileService.saveSchedule(
              schedule: filteredResponse,
              format: _selectedFormat,
              queryValue: widget.params.queryValue,
              shareAfterSave: shareAfterSavig,
            );

            return true;
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('На этот период расписание не найдено'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
            return false;
          }
        },
      );
}

Widget _buildRangeCard(
    ThemeData theme, String label, VoidCallback onTap, String date) {
  return InkWell(
    onTap: onTap,
    child: BorderBox(
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5,
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          Text(
            date,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
