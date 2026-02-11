class ICalendarEvent {
  final String uid;
  final DateTime start;
  final DateTime end;
  final String summary;
  final String? description;
  final String? location;
  final String? organizer;
  final DateTime? created;
  final DateTime? lastModified;
  final String? status;
  final String? sequence;
  final bool isAllDay;
  final List<String>? attendees;
  final Map<String, String>? customProperties;

  ICalendarEvent({
    required this.start,
    required this.end,
    required this.summary,
    this.description,
    this.location,
    this.organizer,
    this.created,
    this.lastModified,
    this.status,
    this.sequence,
    this.isAllDay = false,
    this.attendees,
    this.customProperties,
  }) : uid =  generateUid(start, summary);

  static String generateUid(DateTime start, String summary) {
    final hash = '${start.millisecondsSinceEpoch}-${summary.hashCode}';
    return '$hash@usue-schedule';
  }

  String toICSString() {
    final buffer = StringBuffer();
    
    buffer.writeln('BEGIN:VEVENT');
    
    buffer.writeln('UID:$uid');
    buffer.writeln('DTSTAMP:${_formatDateTime(created ?? DateTime.now())}');
    buffer.writeln('DTSTART${isAllDay ? ';VALUE=DATE' : ''}:${_formatDateTime(start)}');
    buffer.writeln('DTEND${isAllDay ? ';VALUE=DATE' : ''}:${_formatDateTime(end)}');
    buffer.writeln('SUMMARY:${_escapeText(summary)}');
    
    if (description != null && description!.isNotEmpty) {
      buffer.writeln('DESCRIPTION:${_escapeText(description!)}');
    }
    
    if (location != null && location!.isNotEmpty) {
      buffer.writeln('LOCATION:${_escapeText(location!)}');
    }
    
    if (organizer != null && organizer!.isNotEmpty) {
      buffer.writeln('ORGANIZER:mailto:$organizer');
    }
    
    if (lastModified != null) {
      buffer.writeln('LAST-MODIFIED:${_formatDateTime(lastModified!)}');
    }
    
    if (status != null && status!.isNotEmpty) {
      buffer.writeln('STATUS:$status');
    }
    
    if (sequence != null && sequence!.isNotEmpty) {
      buffer.writeln('SEQUENCE:$sequence');
    }
    
    if (attendees != null && attendees!.isNotEmpty) {
      for (final attendee in attendees!) {
        buffer.writeln('ATTENDEE:mailto:$attendee');
      }
    }
    
    if (customProperties != null) {
      for (final entry in customProperties!.entries) {
        buffer.writeln('${entry.key}:${_escapeText(entry.value)}');
      }
    }
    
    buffer.write('END:VEVENT');
    
    return buffer.toString();
  }

  String _formatDateTime(DateTime dt) {
  final utc = dt.toUtc();
  return '${utc.year}'
         '${utc.month.toString().padLeft(2, '0')}'
         '${utc.day.toString().padLeft(2, '0')}'
         'T${utc.hour.toString().padLeft(2, '0')}'
         '${utc.minute.toString().padLeft(2, '0')}'
         '${utc.second.toString().padLeft(2, '0')}Z';
}


  String _escapeText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');
  }
}

class ICalendar {
  final String productId;
  final String version;
  final String calendarName;
  final String timezone;
  final List<ICalendarEvent> events;
  final DateTime? created;
  final String? method;

  ICalendar({
    this.productId = '-//УрГЭУ//Расписание//RU',
    this.version = '2.0',
    this.calendarName = 'Расписание УрГЭУ',
    this.timezone = 'Europe/Yekaterinburg',
    required this.events,
    this.created,
    this.method,
  });

  String generate() {
    final buffer = StringBuffer();
    
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:$version');
    buffer.writeln('PRODID:$productId');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:${method ?? 'PUBLISH'}');
    
    buffer.writeln('X-WR-CALNAME:$calendarName');
    
    buffer.writeln('BEGIN:VTIMEZONE');
    buffer.writeln('TZID:$timezone');
    buffer.writeln('BEGIN:STANDARD');
    buffer.writeln('DTSTART:16010101T030000');
    buffer.writeln('TZOFFSETFROM:+0400');
    buffer.writeln('TZOFFSETTO:+0300');
    buffer.writeln('TZNAME:MSK');
    buffer.writeln('END:STANDARD');
    buffer.writeln('END:VTIMEZONE');
    
    for (final event in events) {
      buffer.writeln(event.toICSString());
    }
    
    buffer.write('END:VCALENDAR');
    
   return buffer
      .toString()
      .replaceAll('\r\n', '\n') 
      .replaceAll('\n', '\r\n');
  }
}