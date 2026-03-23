class DateTimeUtils {
  // Получить дату начала недели (понедельник)
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // Получить дату окончания недели (воскресенье)
  static DateTime getEndOfWeek(DateTime date) {
    final start = getStartOfWeek(date);
    return start.add(const Duration(days: 6));
  }

  // Форматировать дату для отображения
  static String formatDate(DateTime date, {bool showWeekday = true}) {
    final weekday = getWeekdayName(date.weekday);
    final dateStr = '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
    return showWeekday ? '$weekday, $dateStr' : dateStr;
  }

  // Получить название дня недели на русском
  static String getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Понедельник';
      case 2:
        return 'Вторник';
      case 3:
        return 'Среда';
      case 4:
        return 'Четверг';
      case 5:
        return 'Пятница';
      case 6:
        return 'Суббота';
      case 7:
        return 'Воскресенье';
      default:
        return '';
    }
  }

  // Получить название месяца на русском
  static String getMonthName(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Январь';
      case 2:
        return 'Февраль';
      case 3:
        return 'Март';
      case 4:
        return 'Апрель';
      case 5:
        return 'Май';
      case 6:
        return 'Июнь';
      case 7:
        return 'Июль';
      case 8:
        return 'Август';
      case 9:
        return 'Сентябрь';
      case 10:
        return 'Октябрь';
      case 11:
        return 'Ноябрь';
      case 12:
        return 'Декабрь';
      default:
        return '';
    }
  }

  // Парсить дату из строки формата "dd.mm.yyyy"
  static DateTime? parseDate(String dateString) {
    final parts = dateString.split('.');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
    return null;
  }

  // Парсить время из комментария пары
  static String? parseTimeFromComment(String? comment,
      {String defaultTime = ''}) {
    if (comment == null || comment.isEmpty) {
      return defaultTime.isEmpty ? null : defaultTime;
    }

    // Регулярное выражение для поиска времени в формате "ЧЧ.ММ-ЧЧ.ММ"
    final timeRegex = RegExp(r'(\d{1,2})\.(\d{2})-(\d{1,2})\.(\d{2})');

    final match = timeRegex.firstMatch(comment);
    if (match != null) {
      final startHour = match.group(1)!.padLeft(2, '0');
      final startMin = match.group(2)!;
      final endHour = match.group(3)!.padLeft(2, '0');
      final endMin = match.group(4)!;

      // Преобразуем в формат "ЧЧ:ММ-ЧЧ:ММ"
      return '$startHour:$startMin-$endHour:$endMin';
    }

    return defaultTime.isEmpty ? null : defaultTime;
  }

  // Проверить, является ли дата сегодняшней
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Проверить, является ли дата текущей
  static bool isCurrentDate(DateTime date, String dateString) {
    final parsedDate = parseDate(dateString);
    if (parsedDate != null) {
      return isToday(parsedDate);
    }
    return false;
  }

  // Проверяить одинаковые ли даты
  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Проверить, является ли текущая пара
  static bool isCurrentPair(String time, DateTime date) {
    // Если дата не сегодня - сразу false
    if (!isToday(date)) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Парсим время пары из формата "ЧЧ:ММ-ЧЧ:ММ"
    final parts = time.split('-');
    if (parts.length != 2) return false;

    final startParts = parts[0].trim().split(':');
    final endParts = parts[1].trim().split(':');

    if (startParts.length != 2 || endParts.length != 2) return false;

    try {
      final startHour = int.parse(startParts[0]);
      final startMin = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMin = int.parse(endParts[1]);

      final startMinutes = startHour * 60 + startMin;
      final endMinutes = endHour * 60 + endMin;

      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } catch (e) {
      return false;
    }
  }
}
