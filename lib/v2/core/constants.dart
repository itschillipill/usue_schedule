class Constants {
  static String appName= "Расписание УрГЭУ";
  static String author="Абдулвахобов Мехроб Мунимович";
   static String appLinkRuStore =
      "https://www.rustore.ru/catalog/app/com.flutter.m.usue_schedule";
  static String developerLinkRuStore =
      "https://www.rustore.ru/catalog/developer/vsxmns";
  static String version ="3.1.3";
  static String buildNumber ="30";
  static String usueScheduleLink= "https://www.usue.ru/raspisanie/";
  static String devTeam="Команда разработчиков Flutter development";
  static String sign ="© 2026 Разработчики Flutter development";
  static String telegramContact = "https://t.me/itschillipill";

  static Map<int, PairTime> pairTimes = {
    1: PairTime(start: (8, 30), end: (10, 00)),
    2: PairTime(start: (10, 10), end: (11, 40)),
    3: PairTime(start: (12, 10), end: (13, 40)),
    4: PairTime(start: (13, 50), end: (15, 20)),
    5: PairTime(start: (15, 30), end: (17, 00)),
    6: PairTime(start: (17, 10), end: (18, 40)),
    7: PairTime(start: (18, 50), end: (20, 20)),
    8: PairTime(start: (20, 30), end: (22, 00)),
  };
}

class PairTime {
  final (int hour, int minute) start;
  final (int hour, int minute) end;

  PairTime({required this.start, required this.end});

  @override
  String toString() {
    return '${start.$1}:${start.$2}-${end.$1}:${end.$2}';
  }
}
