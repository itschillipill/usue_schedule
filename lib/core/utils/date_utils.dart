class DateTimeUtils {
  // Получить дату начала недели (понедельник)
  static DateTime getStartOfWeek(DateTime date) {
    // В России неделя начинается с понедельника
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
    final weekday = _getWeekdayName(date.weekday);
    final dateStr = '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';

    return showWeekday ? '$weekday, $dateStr' : dateStr;
  }

  // Получить название дня недели на русском
  static String _getWeekdayName(int weekday) {
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
}
