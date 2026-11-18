import 'package:material_ui/material_ui.dart';
import 'package:usue_schedule/features/export/models/export_format.dart';
import 'package:usue_schedule/shared/services/message_service.dart';

import '../../schedule/controllers/schedule_view_provider.dart';
import '../widgets/export_dialog.dart';
import '../widgets/export_format_picker.dart';
import '../widgets/filter_selector.dart';
import '../services/file_service.dart';

class ExportService {
  static Future<void> exportSchedule(
      BuildContext context, ScheduleViewProvider provider,
      {bool shareAfterSave = false}) async {
    String? filter;

    // проверяем есть ли расписание
    if (provider.cuttedResponse == null) return;

    // показываем диалог выбора формата
    ExportFormat? exportFormat = await ExportFormatPicker.show(context);
    if (exportFormat == null) return;
    // if (exportFormat == ExportFormat.pdf ||
    //     exportFormat == ExportFormat.excel) {
    //   MessageService.showSnackBar(
    //       "Ещё не реализован экспорт в формат ${exportFormat.label}");
    //   return;
    // }

    // проверяем есть ли доступные фильтры
    if (provider.hasFilters && context.mounted) {
      // показываем диалог выбора и ждем результат
      final shouldUseFilter = await ExportDialog.show(context);
      if (shouldUseFilter == null) return;

      if (shouldUseFilter && context.mounted) {
        // показываем диалог выбора фильтра
        filter = await FilterSelector.show(context, provider);
      }

      final filtredData = provider.cuttedResponse!
          .getFiltredData(provider.params.scheduleType, filter);

      await MessageService.showLoading<ShareFileData?>(
        message: "Экспорт расписания...",
        delay: const Duration(milliseconds: 350),
        fn: () async {
          if (filtredData.schedules.isEmpty) return null;

          return FileService.saveSchedule(
            dateRange: DateTimeRange(
              start: provider.rangeStart,
              end: provider.rangeEnd,
            ),
            schedule: filtredData,
            format: exportFormat,
            queryValue:
                "${provider.params.queryValue}${filter == null ? '' : ' - $filter'}",
          );
        },
        onSuccess: (result) {
          if (result case final data?) {
            MessageService.showSuccessSnack(
                "Расписание успешно экспортировано");
            if (shareAfterSave) FileService.shareFile(data);
          } else if (shareAfterSave) {
            MessageService.showSnackBar(
              filter != null
                  ? 'На этот период нет расписания для выбранного фильтра'
                  : 'На этот период расписание не найдено',
            );
          }
        },
        onError: (e, stacktrace) {
          MessageService.showErrorSnack("Ошибка при экспорте",
              error: e, stackTrace: stacktrace);
        },
      );
    }
  }
}
