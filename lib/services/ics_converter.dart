import 'package:usue_schedule/core/utils/logger/session_logger.dart';

import '../core/utils/date_utils.dart' as date_utils;
import '../models/i_calendar_event.dart';
import '../models/pair.dart';
import '../models/pair_time.dart';
import '../models/schedule_pair.dart';
import '../models/schedule_response.dart';

class ICalendarConverter {
  static String name = "ICalendarConverter";

  // Основной метод - один календарь для преподавателя
  static ICalendar convertScheduleToCalendar(
    ScheduleResponse schedule,
    String calendarName, {
    String? queryValue,
    bool splitByGroup = false, // Флаг для разделения по группам (если нужно)
    String? timezone,
  }) {
    final events = <ICalendarEvent>[];

    for (final day in schedule.schedules) {
      final dayDate = date_utils.DateTimeUtils.parseDate(day.date);
      if (dayDate == null) continue;

      for (final pair in day.nonEmptyPairs) {
        for (final schedulePair in pair.schedulePairs) {
          final event = _convertPairToEvent(
            schedulePair,
            pair,
            dayDate,
            queryValue: queryValue,
          );
          if (event != null) {
            events.add(event);
          }
        }
      }
    }

    return ICalendar(
      calendarName: calendarName,
      timezone: timezone ?? 'Europe/Yekaterinburg',
      events: events,
    );
  }

  static ICalendarEvent? _convertPairToEvent(
    SchedulePair schedulePair,
    Pair pair,
    DateTime dayDate, {
    String? queryValue,
  }) {
    try {
      // Парсим время начала и окончания
      final timeRange = _parseTimeRange(pair.time);
      if (timeRange == null) return null;

      final PairTime pairTime = PairTime.defaultPairTimes[pair.number] ??
          PairTime(start: (0, 0), end: (0, 0));

      // Создаем DateTime объекты
      final startDateTime = DateTime(
        dayDate.year,
        dayDate.month,
        dayDate.day,
        pairTime.start.$1,
        pairTime.start.$2,
      );

      final endDateTime = DateTime(
        dayDate.year,
        dayDate.month,
        dayDate.day,
        pairTime.end.$1,
        pairTime.end.$2,
      );

      // Формируем описание (все группы в одном событии)
      final description = _buildDescription(schedulePair);

      // Формируем summary с указанием группы
      final summary = _buildSummary(schedulePair);

      // Местоположение
      final location = schedulePair.audience.isNotEmpty
          ? 'Ауд. ${schedulePair.audience}, УрГЭУ'
          : 'УрГЭУ';

      return ICalendarEvent(
        start: startDateTime,
        end: endDateTime,
        summary: summary,
        description: description,
        location: location,
        organizer: schedulePair.teacher,
        created: DateTime.now(),
        lastModified: DateTime.now(),
        status: 'CONFIRMED',
        sequence: '0',
        customProperties: {
          'X-УрГЭУ-Группа': schedulePair.group,
          'X-УрГЭУ-Группа-Чистая': schedulePair.cleanGroup,
          'X-УрГЭУ-Подгруппа': schedulePair.subgroupNumber?.toString() ?? '',
          'X-УрГЭУ-Тип-Занятия': schedulePair.lessonType,
          'X-УрГЭУ-Преподаватель-ID': schedulePair.teacherId.toString(),
          'X-УрГЭУ-Группа-ID': schedulePair.groupId.toString(),
          'X-УрГЭУ-Пара-ID': schedulePair.pairId.toString(),
        },
      );
    } catch (e) {
      SessionLogger.instance
          .error(name, "Ошибка конвертации пары в событие", error: e);
      return null;
    }
  }

  // Метод для преподавателя - ВСЕ группы в ОДНОМ файле
  static ICalendar $convertScheduleToCalendar(
    ScheduleResponse schedule,
    String queryValue,
  ) {
    final events = <ICalendarEvent>[];
    final eventsByTimeSlot = <String, List<ICalendarEvent>>{};

    // Сначала группируем события по дате и времени
    for (final day in schedule.schedules) {
      final dayDate = date_utils.DateTimeUtils.parseDate(day.date);
      if (dayDate == null) continue;

      for (final pair in day.nonEmptyPairs) {
        for (final schedulePair in pair.schedulePairs) {
          final event = _convertPairToEvent(
            schedulePair,
            pair,
            dayDate,
            queryValue: queryValue,
          );

          if (event != null) {
            final timeSlotKey = '${day.date}_${pair.time}';
            eventsByTimeSlot.putIfAbsent(timeSlotKey, () => []).add(event);
          }
        }
      }
    }

    // Теперь объединяем события в одни и те же слоты времени
    for (final slotEvents in eventsByTimeSlot.values) {
      if (slotEvents.length == 1) {
        // Одно событие в слоте - добавляем как есть
        events.add(slotEvents.first);
      } else {
        // Несколько событий в одном временном слоте
        // Объединяем их в одно событие
        final mergedEvent = _mergeEvents(slotEvents, queryValue);
        if (mergedEvent != null) {
          events.add(mergedEvent);
        }
      }
    }

    return ICalendar(
      calendarName: 'Расписание: $queryValue',
      events: events,
    );
  }

  // Объединение нескольких событий в один временной слот
  static ICalendarEvent? _mergeEvents(
      List<ICalendarEvent> events, String queryValue) {
    if (events.isEmpty) return null;

    // Берем первое событие как базовое
    final firstEvent = events.first;

    // Собираем информацию о всех группах
    final groups = <String>{};
    final subjects = <String>{};
    final audiences = <String>{};
    final descriptions = <String>{};

    for (final event in events) {
      final group = event.customProperties?['X-УрГЭУ-Группа'] ?? '';
      final subject = _extractSubjectFromSummary(event.summary);
      final audience =
          event.location?.replaceAll('Ауд. ', '').replaceAll(', УрГЭУ', '') ??
              '';

      if (group.isNotEmpty) groups.add(group);
      if (subject.isNotEmpty) subjects.add(subject);
      if (audience.isNotEmpty) audiences.add(audience);

      if (event.description != null) {
        descriptions.add(event.description!);
      }
    }

    // Создаем объединенный summary
    final subjectStr = subjects.join('/');
    final groupsStr = groups.join(', ');
    final summary = '$subjectStr ($groupsStr)';

    // Создаем объединенное описание
    final descriptionBuffer = StringBuffer();
    descriptionBuffer.writeln('Преподаватель: ${events.first.organizer}');
    descriptionBuffer.writeln('Группы: ${groups.join(', ')}');

    if (subjects.isNotEmpty) {
      descriptionBuffer.writeln('Предметы: ${subjects.join('/')}');
    }

    if (audiences.isNotEmpty) {
      descriptionBuffer.writeln('Аудитории: ${audiences.join(', ')}');
    }

    descriptionBuffer.writeln('');
    descriptionBuffer.write('Создано в приложении "Расписание УрГЭУ"');

    // Создаем объединенное местоположение
    final location =
        audiences.isNotEmpty ? 'Ауд. ${audiences.join(', ')}, УрГЭУ' : 'УрГЭУ';

    return ICalendarEvent(
      start: firstEvent.start,
      end: firstEvent.end,
      summary: summary,
      description: descriptionBuffer.toString(),
      location: location,
      organizer: events.first.organizer,
      created: DateTime.now(),
      lastModified: DateTime.now(),
      status: 'CONFIRMED',
      sequence: '0',
      customProperties: {
        'X-УрГЭУ-Группы': groups.join(';'),
        'X-УрГЭУ-Предметы': subjects.join(';'),
        'X-УрГЭУ-Аудитории': audiences.join(';'),
        'X-УрГЭУ-Объединено-Событий': events.length.toString(),
      },
    );
  }

  static String _extractSubjectFromSummary(String summary) {
    // Убираем группу из summary, если есть в скобках
    final regex = RegExp(r'^(.*?)\s*\([^)]*\)$');
    final match = regex.firstMatch(summary);
    return match?.group(1)?.trim() ?? summary;
  }

  static (DateTime start, DateTime end)? _parseTimeRange(String timeString) {
    try {
      final parts = timeString.split('-');
      if (parts.length != 2) return null;

      final startParts = parts[0].trim().split(':');
      final endParts = parts[1].trim().split(':');

      if (startParts.length != 2 || endParts.length != 2) return null;

      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      final now = DateTime.now();

      return (
        DateTime(now.year, now.month, now.day, startHour, startMinute),
        DateTime(now.year, now.month, now.day, endHour, endMinute),
      );
    } catch (e) {
      SessionLogger.instance.error(name, "Ошибка парсинга времени", error: e);
      return null;
    }
  }

  static String _buildDescription(SchedulePair schedulePair) {
    final buffer = StringBuffer();

    buffer.writeln('Предмет: ${schedulePair.subject}');
    buffer.writeln('Тип занятия: ${schedulePair.lessonType}');
    buffer.writeln('Группа: ${schedulePair.group}');
    buffer.writeln('Преподаватель: ${schedulePair.teacher}');

    if (schedulePair.audience.isNotEmpty) {
      buffer.writeln('Аудитория: ${schedulePair.audience}');
    }

    if (schedulePair.comment.isNotEmpty) {
      buffer.writeln('Примечание: ${schedulePair.comment}');
    }

    buffer.writeln('');
    buffer.write('Создано в приложении "Расписание УрГЭУ"');

    return buffer.toString();
  }

  static String _buildSummary(SchedulePair schedulePair) {
    final parts = <String>[];

    // Добавляем предмет
    parts.add(schedulePair.subject);

    // Добавляем группу (укороченную версию если длинная)
    String groupDisplay = schedulePair.group;
    if (groupDisplay.length > 15) {
      groupDisplay = schedulePair.cleanGroup;
    }
    parts.add('($groupDisplay)');

    // Добавляем тип занятия если не "Занятие"
    if (schedulePair.lessonType != 'Занятие') {
      parts.add('(${schedulePair.lessonType})');
    }

    return parts.join(' ');
  }
}
