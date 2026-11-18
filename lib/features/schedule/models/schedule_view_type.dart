import 'package:material_ui/material_ui.dart' show IconData, Icons;

enum ScheduleViewType {
  day("День", Icons.today_outlined),
  week("Неделя", Icons.view_week_outlined),
  month("Месяц", Icons.calendar_month_outlined),
  custom("Произвольно", Icons.date_range_outlined);

  final String text;
  final IconData icon;
  const ScheduleViewType(this.text, this.icon);
}
