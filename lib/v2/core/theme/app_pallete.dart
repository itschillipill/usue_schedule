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

  // Акцентные цвета для фильтров
  static const Color amber = Color(0xFFFFB74D); // Для выделенных фильтров
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

  // Прозрачность
  static const Color transparent = Colors.transparent;

  // Цвета для групп (для фильтров)
  static List<Color> groupColors = [
    bluePrimary,
    green,
    orange,
    purple,
    teal,
    Color(0xFFE91E63), // Розовый
    Color(0xFF3F51B5), // Индиго
    Color(0xFF00BCD4), // Голубой
  ];
}
