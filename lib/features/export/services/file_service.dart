import 'dart:convert' show Utf8Codec;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usue_schedule/core/utils/date_utils.dart';

import '../../../core/logger/session_logger.dart';
import '../models/export_format.dart';
import '../../schedule/models/schedule_response.dart';
import 'ics_converter.dart';

class FileService {
  static String name = "FileService";

  static Future<void> saveSchedule({
    required DateTimeRange dateRange,
    required ScheduleResponse schedule,
    required ExportFormat format,
    String? queryValue,
    bool shareAfterSave = true,
  }) async {
    if (Platform.isAndroid) {
      await _handleAndroidPermissions();
    }
    final fileName =
        'Расписание_УрГЭУ_${queryValue}_(${DateTimeUtils.formatDate(dateRange.start, showWeekday: false)}-${DateTimeUtils.formatDate(dateRange.end, showWeekday: false)})';

    final String path = switch (format) {
      ExportFormat.pdf => await _saveAsPdf(schedule, fileName),
      ExportFormat.excel => await _saveAsExcel(schedule, fileName),
      ExportFormat.ics => await _saveAsICS(schedule, fileName, queryValue),
    };

    SessionLogger.instance.debug(name, "✅ Файл сохранён: $path");

    if (shareAfterSave) {
      await _shareFile(path, format);
    }
  }

  static Future<void> _handleAndroidPermissions() async {
    final info = await DeviceInfoPlugin().androidInfo;

    if (info.version.sdkInt <= 28) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception("Нет разрешения на доступ к хранилищу");
      }
    }
  }

  static Future<String> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      return dir.path;
    }

    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }

    final dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
    return dir.path;
  }

  static Future<String> _saveAsICS(
    ScheduleResponse schedule,
    String fileName,
    String? queryValue,
  ) async {
    SessionLogger.instance.debug(name, "📅 Экспорт в iCalendar (.ics)");

    final calendar = ICalendarConverter.$convertScheduleToCalendar(
      schedule,
      queryValue ?? "",
    );

    final icsContent = calendar.generate();

    final dir = await _getSaveDirectory();
    final safeFileName = _sanitizeFileName('$fileName.ics');
    final file = File('$dir/$safeFileName');

    final bom = String.fromCharCode(0xFEFF);
    await file.writeAsString(
      '$bom$icsContent',
      encoding: const Utf8Codec(allowMalformed: false),
    );

    SessionLogger.instance.debug(name,
        "📊 Создано событий: ${calendar.events.length}\n📁 Путь: ${file.path}");

    return file.path;
  }

  static Future<String> _saveAsPdf(
    ScheduleResponse schedule,
    String fileName,
  ) async {
    final dir = await _getSaveDirectory();
    final name = _sanitizeFileName('$fileName.pdf');
    final file = File('$dir/$name');

    await file.writeAsString('PDF экспорт будет реализован позже');

    return file.path;
  }

  static Future<String> _saveAsExcel(
    ScheduleResponse schedule,
    String fileName,
  ) async {
    final dir = await _getSaveDirectory();
    final name = _sanitizeFileName('$fileName.xlsx');
    final file = File('$dir/$name');

    await file.writeAsString('Excel экспорт будет реализован позже');

    return file.path;
  }

  static Future<void> _shareFile(String filePath, ExportFormat format) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("Файл не найден: $filePath");
    }

    final mimeType = switch (format) {
      ExportFormat.pdf => 'application/pdf',
      ExportFormat.excel =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ExportFormat.ics => 'text/calendar',
    };

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: mimeType)],
        subject: 'Расписание УрГЭУ',
        text: 'Экспорт расписания в ${format.name}',
      ),
    );
  }

  static String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
