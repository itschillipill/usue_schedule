class PairTime{
  final (int hour, int minute) start;
  final (int hour, int minute) end;

  const PairTime({
    required this.start,
    required this.end,
  });

  static const Map<int, PairTime> defaultPairTimes = {
    1: PairTime(start: (8, 30), end: (10, 0)),
    2: PairTime(start: (10, 10), end: (11, 40)),
    3: PairTime(start: (11, 50), end: (13, 20)),
    4: PairTime(start: (13, 50), end: (15, 20)),
    5: PairTime(start: (15, 30), end: (17, 0)),
    6: PairTime(start: (17, 10), end: (18, 40)),
    7: PairTime(start: (18, 50), end: (20, 20)),
    8: PairTime(start: (20, 30), end: (22, 0)),
  };

  // Конструктор для удобства создания
  factory PairTime.fromStrings(String startTime, String endTime) {
    final startParts = startTime.split(':').map(int.parse).toList();
    final endParts = endTime.split(':').map(int.parse).toList();

    return PairTime(
      start: (startParts[0], startParts[1]),
      end: (endParts[0], endParts[1]),
    );
  }

  // Проверка, идет ли пара сейчас
  bool isCurrent() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final startMinutes = start.$1 * 60 + start.$2;
    final endMinutes = end.$1 * 60 + end.$2;

    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }

  static bool isCurrentPair(int pairNumber, {DateTime? date}) {
    // Проверяем, что сегодня
    final now = DateTime.now();
    if (date != null) {
      if (date.year != now.year ||
          date.month != now.month ||
          date.day != now.day) {
        return false;
      }
    }

    final pairTime = defaultPairTimes[pairNumber];
    if (pairTime == null) return false;

    return pairTime.isCurrent();
  }

  // Получить время в формате "8:30-10:00"
  @override
  String toString() {
    return '${start.$1}:${start.$2.toString().padLeft(2, '0')}-'
        '${end.$1}:${end.$2.toString().padLeft(2, '0')}';
  }
}
