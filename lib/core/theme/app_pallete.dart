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

  // --- ПАЛИТРА ДЛЯ СВЕТЛОЙ ТЕМЫ (20 цветов) ---
  // Глубокие, насыщенные цвета для белого фона
  static const List<Color> lightGroupColors = [
    Color(0xFFD32F2F), // 1. Красный (Deep Red)
    Color(0xFF1976D2), // 2. Синий (Deep Blue)
    Color(0xFF388E3C), // 3. Зеленый (Forest Green)
    Color(0xFF7B1FA2), // 4. Фиолетовый (Purple)
    Color(0xFFC2185B), // 5. Розовый (Berry)
    Color(0xFF00796B), // 6. Бирюзовый (Teal)
    Color(0xFFE65100), // 7. Оранжевый (Burnt Orange)
    Color(0xFF303F9F), // 8. Индиго (Navy)
    Color(0xFF5D4037), // 9. Коричневый (Coffee)
    Color(0xFF455A64), // 10. Серо-синий (Slate)
    Color(0xFF00838F), // 11. Циан (Dark Cyan)
    Color(0xFFF9A825), // 12. Янтарный (Dark Amber)
    Color(0xFF2E7D32), // 13. Темно-зеленый (Emerald)
    Color(0xFF6A1B9A), // 14. Глубокий пурпур (Grape)
    Color(0xFFBF360C), // 15. Красно-оранжевый (Rust)
    Color(0xFF0277BD), // 16. Голубой (Ocean Blue)
    Color(0xFF827717), // 17. Оливковый (Olive)
    Color(0xFFAD1457), // 18. Малиновый (Crimson)
    Color(0xFF1565C0), // 19. Ярко-синий (Azure)
    Color(0xFF37474F), // 20. Темный графит (Charcoal)
  ];

  // --- ПАЛИТРА ДЛЯ ТЕМНОЙ ТЕМЫ (20 цветов) ---
  // Светлые, пастельные и неоновые цвета для черного фона
  static const List<Color> darkGroupColors = [
    Color(0xFFEF9A9A), // 1. Нежно-красный
    Color(0xFF90CAF9), // 2. Светло-голубой
    Color(0xFFA5D6A7), // 3. Мятный
    Color(0xFFCE93D8), // 4. Лавандовый
    Color(0xFFF48FB1), // 5. Розовый лепесток
    Color(0xFF80CBC4), // 6. Аквамарин
    Color(0xFFFFCC80), // 7. Персиковый
    Color(0xFF9FA8DA), // 8. Светлый индиго
    Color(0xFFBCAAA4), // 9. Бежево-коричневый
    Color(0xFFB0BEC5), // 10. Светло-серый
    Color(0xFF80DEEA), // 11. Светлый циан
    Color(0xFFFFF59D), // 12. Лимонный пастельный
    Color(0xFFC5E1A5), // 13. Светлый лайм
    Color(0xFFE1BEE7), // 14. Нежно-пурпурный
    Color(0xFFFFAB91), // 15. Коралловый
    Color(0xFF81D4FA), // 16. Небесный
    Color(0xFFE6EE9C), // 17. Салатовый
    Color(0xFFF06292), // 18. Яркий розовый (светлый)
    Color(0xFF1DE9B6), // 19. Неоновая бирюза
    Color(0xFFB2FF59), // 20. Яркий лайм
  ];
}
