import 'package:flutter/material.dart';

class AppPallete {
  // Основные цвета
  static const Color bluePrimary = Color(0xFF0066CC); // Синий акцент
  static const Color blueSecondary = Color(0xFF0088FF); // Светло-синий
  static const Color blueDark = Color(0xFF004C99); // Темно-синий
  static const Color blueLight = Color(0xFFE6F2FF); // Очень светлый синий

  // Нейтральные цвета
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Акцентные цвета
  static const Color amber = Color(0xFFFFB74D);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color orange = Color(0xFFFF9800);
  static const Color purple = Color(0xFF9C27B0);
  static const Color teal = Color(0xFF009688);

  // Цвета состояний
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Градиенты
  static const List<Color> blueGradient = [bluePrimary, blueSecondary];
  static const List<Color> darkGradient = [grey900, grey800];

  static const Color transparent = Colors.transparent;

  // различные цвета для групп, ярких и легко различимых
// Оптимизировано для максимального контраста между соседними цветами
  static const List<Color> groupColors = [
    Color(0xFFE53935), // красный
    Color(0xFF1E88E5), // голубой
    Color(0xFF43A047), // зеленый
    Color(0xFF8E24AA), // фиолетовый
    Color(0xFFD81B60), // розовый
    Color(0xFF00897B), // бирюзовый
    Color(0xFF5E35B1), // индиго
    Color(0xFFFF7043), // оранжевый
    Color(0xFF00ACC1), // аквамарин
    Color(0xFF6D4C41), // коричневый
    Color(0xFF3949AB), // синий
    Color(0xFFC0CA33), // салатовый
    Color(0xFF00E676), // ярко-зеленый
    Color(0xFFE91E63), // малиновый
    Color(0xFF0288D1), // темно-голубой
    Color(0xFFFFA726), // оранжевый
    Color(0xFF673AB7), // темно-фиолетовый
    Color(0xFF4DD0E1), // светло-бирюзовый
    Color(0xFFD81B60), // розово-красный
    Color(0xFF26C6DA), // циан
    Color(0xFFFDD835), // желтый
    Color(0xFF7CB342), // светло-зеленый
    Color(0xFF546E7A), // серо-синий
    Color(0xFFE53935), // красный (для цикла)
    Color(0xFF1DE9B6), // мятный
    Color(0xFF9C27B0), // пурпурный
    Color(0xFFFF8A65), // коралловый
    Color(0xFF039BE5), // синий
    Color(0xFF4FC3F7), // небесный
    Color(0xFFFFAB91), // персиковый
    Color(0xFF880E4F), // темно-розовый
    Color(0xFF01579B), // темно-синий
    Color(0xFFB2FF59), // лайм
    Color(0xFF00ACC1), // бирюзовый
    Color(0xFFE65100), // темно-оранжевый
    Color(0xFFAD1457), // бордовый
    Color(0xFF283593), // индиго
    Color(0xFF2E7D32), // темно-зеленый
    Color(0xFF00695C), // темно-бирюзовый
    Color(0xFF4A148C), // темно-фиолетовый
    Color(0xFFB71C1C), // темно-красный
    Color(0xFF0D47A1), // темно-синий
    Color(0xFF1B5E20), // темно-зеленый
    Color(0xFFBF360C), // красно-оранжевый
    Color(0xFF311B92), // темно-фиолетовый
    Color(0xFF1A237E), // темно-синий
    Color(0xFF004D40), // темно-бирюзовый
    Color(0xFF827717), // оливковый
    Color(0xFF3E2723), // темно-коричневый
  ];
}
