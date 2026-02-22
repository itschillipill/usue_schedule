import 'package:flutter_test/flutter_test.dart';
import 'package:usue_schedule/core/utils/date_utils.dart';

void main() {
  group('DateTimeUtilsTest', () {
    test("getStartOfWeek", () {
      final date = DateTime(2026, 2, 19); // Четверг 19 февраля 2026 года
      // ignore: no_leading_underscores_for_local_identifiers
      final _startOfWeek =
          DateTime(2026, 2, 16); // Понедельник 16 февраля 2026 года
      final startOfWeek = DateTimeUtils.getStartOfWeek(date);
      expect(startOfWeek.day, _startOfWeek.day);
      expect(startOfWeek.month, _startOfWeek.month);
      expect(startOfWeek.year, _startOfWeek.year);
    });
    test('getEndOfWeek', () {
      final date = DateTime(2026, 2, 19); // Четверг 19 февраля 2026 года
      // ignore: no_leading_underscores_for_local_identifiers
      final _endOfWeek =
          DateTime(2026, 2, 22); // Воскресенье 22 февраля 2026 года
      final endOfWeek = DateTimeUtils.getEndOfWeek(date);
      expect(endOfWeek.day, _endOfWeek.day);
      expect(endOfWeek.month, _endOfWeek.month);
      expect(endOfWeek.year, _endOfWeek.year);
    });

    test('formatDate', () {
      final date = DateTime(2026, 2, 19); // Четверг 19 февраля 2026 года
      final formattedDate = DateTimeUtils.formatDate(date);
      final formattedDateWithoutWeekDay =
          DateTimeUtils.formatDate(date, showWeekday: false);
      expect(formattedDate, 'Четверг, 19.02.2026');
      expect(formattedDateWithoutWeekDay, '19.02.2026');
    });

    test('getWeekdayName', () {
      expect(DateTimeUtils.getWeekdayName(1), 'Понедельник');
      expect(DateTimeUtils.getWeekdayName(2), 'Вторник');
      expect(DateTimeUtils.getWeekdayName(3), 'Среда');
      expect(DateTimeUtils.getWeekdayName(4), 'Четверг');
      expect(DateTimeUtils.getWeekdayName(5), 'Пятница');
      expect(DateTimeUtils.getWeekdayName(6), 'Суббота');
      expect(DateTimeUtils.getWeekdayName(7), 'Воскресенье');
      expect(DateTimeUtils.getWeekdayName(10000), '');
    });

    test('parseDate', () {
      String dateString = '19.02.2026';
      final parsedDate = DateTimeUtils.parseDate(dateString);
      expect(parsedDate?.day, 19);
      expect(parsedDate?.month, 2);
      expect(parsedDate?.year, 2026);
    });

    test("isToday", () {
      final date = DateTime.now();
      expect(DateTimeUtils.isToday(date), true);
      expect(
          DateTimeUtils.isToday(date.subtract(const Duration(days: 1))), false);
      expect(DateTimeUtils.isToday(date.add(const Duration(days: 1))), false);
    });

    test('IsCurrentDate', () {
      final date = DateTime.now();
      String dateString =
          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
      expect(DateTimeUtils.isCurrentDate(date, dateString), true);
      expect(DateTimeUtils.isCurrentDate(date, '01.01.1999'), false);
    });
  });
}
