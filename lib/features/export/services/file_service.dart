// ignore_for_file: unused_element

import 'dart:convert' show utf8;
import 'dart:io' show Platform, File;
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' show getDownloadsDirectory;
import 'package:share_plus/share_plus.dart';
import 'package:usue_schedule/core/utils/date_utils.dart';
import '../../../core/logger/session_logger.dart';
import '../models/export_format.dart';
import '../../schedule/models/schedule_response.dart';
import 'ics_converter.dart';
import 'docx_generator.dart';

const platform = MethodChannel('app.channel.files');

class FileService {
  static String name = "FileService";

  // Базовый метод сохранения файла в Downloads
  static Future<String?> saveToDownloads(
      String fileName, Uint8List bytes) async {
    try {
      if (Platform.isAndroid) {
        // Android использует нативный код
        final path = await platform.invokeMethod('saveFile', {
          'fileName': fileName,
          'bytes': bytes,
        });
        return path as String?;
      } else {
        // Для других платформ
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('Could not find Downloads directory');
        }

        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      }
    } catch (e, s) {
      SessionLogger.instance
          .error(name, "Ошибка сохранения", error: e, stackTrace: s);
      rethrow;
    }
  }

  // Основной метод сохранения расписания в разных форматах
  static Future<void> saveSchedule({
    required DateTimeRange dateRange,
    required ScheduleResponse schedule,
    required ExportFormat format,
    String? queryValue,
    bool shareAfterSave = true,
  }) async {
    final fileName = _generateFileName(dateRange, queryValue);

     final Uint8List bytes = switch (format) {
       ExportFormat.ics => await _saveAsICS(schedule, fileName, queryValue),
      ExportFormat.word => await _saveAsWord(schedule, fileName),
    };

   SessionLogger.instance.debug(name, "✅ Файл сохранён");

    if (shareAfterSave) {
      await _shareFile(fileName, bytes, format);
    }
  }

  // Генерация имени файла
  static String _generateFileName(DateTimeRange dateRange, String? queryValue) {
    final baseName =
        'Расписание_УрГЭУ_${queryValue ?? ""}_(${DateTimeUtils.formatDate(dateRange.start, showWeekday: false)}-${DateTimeUtils.formatDate(dateRange.end, showWeekday: false)})';
    return _sanitizeFileName(baseName);
  }

  static Future<Uint8List> _saveAsWord(
      ScheduleResponse schedule, String fileName) async {
    final bytes = DocxGenerator.create(schedule, fileName);

    // Важно: расширение теперь .docx
    final safeFileName = '$fileName.docx';
     saveToDownloads(safeFileName, bytes);
     return bytes;
  }

  // Сохранение в ICS
  static Future<Uint8List> _saveAsICS(
      ScheduleResponse schedule, String fileName, String? queryValue) async {
    SessionLogger.instance.debug(name, "📅 Экспорт в iCalendar (.ics)");

    final calendar = ICalendarConverter.$convertScheduleToCalendar(
      schedule,
      queryValue ?? "",
    );

    final icsContent = calendar.generate();
    final bytes = utf8.encode('\ufeff$icsContent');

    final safeFileName = '$fileName.ics';
     saveToDownloads(safeFileName, Uint8List.fromList(bytes));
     return bytes;
  }

  // Сохранение в PDF (заглушка)
  static Future<String?> _saveAsPdf(
      ScheduleResponse schedule, String fileName) async {
    final bytes = utf8.encode('PDF экспорт будет реализован позже');
    final safeFileName = '$fileName.pdf';
    return saveToDownloads(safeFileName, Uint8List.fromList(bytes));
  }

  // Сохранение в Excel (заглушка)
  static Future<String?> _saveAsExcel(
      ScheduleResponse schedule, String fileName) async {
    final bytes = utf8.encode('Excel экспорт будет реализован позже');
    final safeFileName = '$fileName.xlsx';
    return saveToDownloads(safeFileName, Uint8List.fromList(bytes));
  }

  // Шеринг файла
  static Future<void> _shareFile(String fileName, Uint8List bytes, ExportFormat format) async {
    final mimeType = switch (format) {
      // ExportFormat.pdf => 'application/pdf',
      // ExportFormat.excel =>
      //   'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ExportFormat.ics => 'text/calendar',
      ExportFormat.word => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    await SharePlus.instance.share(
      ShareParams(
    files: [
      XFile.fromData(
        bytes,
        name: '$fileName.${format.extension}',
        mimeType: mimeType,
      )
    ],
  ),
);
  }

  // Очистка имени файла от недопустимых символов
  static String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
