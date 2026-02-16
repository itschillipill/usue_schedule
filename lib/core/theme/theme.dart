import 'package:flutter/material.dart';

import 'app_pallete.dart';

class AppTheme {
  // Текст
  static TextStyle _textStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontFamily: 'Roboto',
    );
  }

  // Границы
  static OutlineInputBorder _border({
    Color color = AppPallete.grey300,
    double width = 1,
    double radius = 12,
  }) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
        borderRadius: BorderRadius.circular(radius),
      );

  // Тень
  static List<BoxShadow> _shadow({
    Color color = Colors.black12,
    double blur = 8,
    double offset = 2,
  }) =>
      [
        BoxShadow(
          color: color,
          blurRadius: blur,
          offset: Offset(0, offset),
        ),
      ];

  // Темная тема
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    // Основные цвета
    colorScheme: const ColorScheme.dark(
      primary: AppPallete.bluePrimary,
      secondary: AppPallete.blueSecondary,
      surface: AppPallete.grey900,
      onSurface: AppPallete.white,
      error: AppPallete.error,
    ),

    // Фон
    scaffoldBackgroundColor: AppPallete.grey900,
    canvasColor: AppPallete.grey800,
    cardColor: AppPallete.grey800,
    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppPallete.grey900,
      foregroundColor: AppPallete.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      surfaceTintColor: AppPallete.bluePrimary,
      titleTextStyle: _textStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppPallete.white,
      ),
    ),

    // Карточки
    cardTheme: CardThemeData(
      color: AppPallete.grey800,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppPallete.grey700, width: 1),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    // Кнопки
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.bluePrimary,
        foregroundColor: AppPallete.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: _textStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppPallete.white,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppPallete.blueSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppPallete.blueSecondary,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPallete.blueSecondary,
        side: BorderSide(color: AppPallete.blueSecondary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: _textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppPallete.blueSecondary,
        ),
      ),
    ),

    // Чипы (фильтры)
    chipTheme: ChipThemeData(
      backgroundColor: AppPallete.grey700,
      disabledColor: AppPallete.grey600,
      selectedColor: AppPallete.bluePrimary,
      secondarySelectedColor: AppPallete.amber,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: _textStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppPallete.white,
      ),
      secondaryLabelStyle: _textStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppPallete.white,
      ),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),

    // Поля ввода
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPallete.grey800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _border(color: AppPallete.grey700, radius: 12),
      enabledBorder: _border(color: AppPallete.grey700, radius: 12),
      focusedBorder:
          _border(color: AppPallete.bluePrimary, width: 2, radius: 12),
      errorBorder: _border(color: AppPallete.error, radius: 12),
      focusedErrorBorder:
          _border(color: AppPallete.error, width: 2, radius: 12),
      labelStyle: _textStyle(
        fontSize: 14,
        color: AppPallete.grey400,
      ),
      hintStyle: _textStyle(
        fontSize: 14,
        color: AppPallete.grey500,
      ),
      errorStyle: _textStyle(
        fontSize: 12,
        color: AppPallete.error,
      ),
      helperStyle: _textStyle(
        fontSize: 12,
        color: AppPallete.grey400,
      ),
    ),

    // Иконки
    iconTheme: const IconThemeData(
      color: AppPallete.white,
      size: 24,
    ),

    // Свитчи
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.bluePrimary;
        }
        return AppPallete.grey400;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.bluePrimary.withValues(alpha: 0.5);
        }
        return AppPallete.grey600;
      }),
    ),

    // Разделители
    dividerTheme: const DividerThemeData(
      color: AppPallete.grey700,
      thickness: 1,
      space: 0,
    ),

    // Подсказки (Tooltips)
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppPallete.grey800,
        borderRadius: BorderRadius.circular(8),
        boxShadow: _shadow(),
      ),
      textStyle: _textStyle(
        fontSize: 13,
        color: AppPallete.white,
      ),
    ),

    // Стили текста
    textTheme: TextTheme(
      displayLarge: _textStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppPallete.white,
      ),
      displayMedium: _textStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppPallete.white,
      ),
      displaySmall: _textStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppPallete.white,
      ),
      headlineMedium: _textStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppPallete.white,
      ),
      headlineSmall: _textStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppPallete.white,
      ),
      titleLarge: _textStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppPallete.white,
      ),
      titleMedium: _textStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppPallete.white,
      ),
      titleSmall: _textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppPallete.white,
      ),
      bodyLarge: _textStyle(
        fontSize: 16,
        color: AppPallete.grey200,
      ),
      bodyMedium: _textStyle(
        fontSize: 14,
        color: AppPallete.grey300,
      ),
      bodySmall: _textStyle(
        fontSize: 12,
        color: AppPallete.grey400,
      ),
      labelLarge: _textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppPallete.white,
      ),
      labelMedium: _textStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppPallete.grey400,
      ),
      labelSmall: _textStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppPallete.grey500,
      ),
    ),
  );

  // Светлая тема
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    // Основные цвета
    colorScheme: const ColorScheme.light(
      primary: AppPallete.bluePrimary,
      secondary: AppPallete.blueSecondary,
      surface: AppPallete.white,
      onSurface: AppPallete.grey900,
      error: AppPallete.error,
    ),

    // Фон
    scaffoldBackgroundColor: AppPallete.grey50,
    canvasColor: AppPallete.white,
    cardColor: AppPallete.white,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppPallete.white,
      foregroundColor: AppPallete.grey900,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      surfaceTintColor: AppPallete.white,
      titleTextStyle: _textStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppPallete.grey900,
      ),
    ),

    // Карточки
    cardTheme: CardThemeData(
      color: AppPallete.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppPallete.grey200, width: 1),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    // Кнопки
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.bluePrimary,
        foregroundColor: AppPallete.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: _textStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppPallete.white,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppPallete.bluePrimary,
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppPallete.bluePrimary,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPallete.bluePrimary,
        side: BorderSide(color: AppPallete.bluePrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: _textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppPallete.bluePrimary,
        ),
      ),
    ),

    // Чипы (фильтры)
    chipTheme: ChipThemeData(
      backgroundColor: AppPallete.grey100,
      disabledColor: AppPallete.grey200,
      selectedColor: AppPallete.blueLight,
      secondarySelectedColor: AppPallete.amber,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: _textStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppPallete.grey800,
      ),
      secondaryLabelStyle: _textStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppPallete.blueDark,
      ),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPallete.grey200),
      ),
    ),

    // Поля ввода
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPallete.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _border(color: AppPallete.grey300, radius: 12),
      enabledBorder: _border(color: AppPallete.grey300, radius: 12),
      focusedBorder:
          _border(color: AppPallete.bluePrimary, width: 2, radius: 12),
      errorBorder: _border(color: AppPallete.error, radius: 12),
      focusedErrorBorder:
          _border(color: AppPallete.error, width: 2, radius: 12),
      labelStyle: _textStyle(
        fontSize: 14,
        color: AppPallete.grey600,
      ),
      hintStyle: _textStyle(
        fontSize: 14,
        color: AppPallete.grey500,
      ),
      errorStyle: _textStyle(
        fontSize: 12,
        color: AppPallete.error,
      ),
      helperStyle: _textStyle(
        fontSize: 12,
        color: AppPallete.grey500,
      ),
    ),

    // Иконки
    iconTheme: const IconThemeData(
      color: AppPallete.grey700,
      size: 24,
    ),

    // Свитчи
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.bluePrimary;
        }
        return AppPallete.grey400;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.bluePrimary.withValues(alpha: 0.3);
        }
        return AppPallete.grey300;
      }),
    ),

    // Разделители
    dividerTheme: const DividerThemeData(
      color: AppPallete.grey200,
      thickness: 1,
      space: 0,
    ),

    // Подсказки (Tooltips)
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppPallete.grey800,
        borderRadius: BorderRadius.circular(8),
        boxShadow: _shadow(),
      ),
      textStyle: _textStyle(
        fontSize: 13,
        color: AppPallete.white,
      ),
    ),

    // Стили текста
    textTheme: TextTheme(
      displayLarge: _textStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppPallete.grey900,
      ),
      displayMedium: _textStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppPallete.grey900,
      ),
      displaySmall: _textStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppPallete.grey900,
      ),
      headlineMedium: _textStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppPallete.grey900,
      ),
      headlineSmall: _textStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppPallete.grey900,
      ),
      titleLarge: _textStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppPallete.grey800,
      ),
      titleMedium: _textStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppPallete.grey800,
      ),
      titleSmall: _textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppPallete.grey800,
      ),
      bodyLarge: _textStyle(
        fontSize: 16,
        color: AppPallete.grey700,
      ),
      bodyMedium: _textStyle(
        fontSize: 14,
        color: AppPallete.grey600,
      ),
      bodySmall: _textStyle(
        fontSize: 12,
        color: AppPallete.grey500,
      ),
      labelLarge: _textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppPallete.grey900,
      ),
      labelMedium: _textStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppPallete.grey600,
      ),
      labelSmall: _textStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppPallete.grey500,
      ),
    ),
  );
}

// Расширение для удобного доступа к теме
extension ThemeExtension on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get cardColor => Theme.of(this).cardColor;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Цвета для групп (учитывает тему)
  Color getGroupColor(int index) {
    final colors = AppPallete.groupColors;
    return colors[index % colors.length];
  }

  // Цвет для текущей пары
  Color get currentPairColor => isDarkMode
      ? AppPallete.orange.withValues(alpha: 0.2)
      : AppPallete.orange.withValues(alpha: 0.1);

  // Цвет для сегодняшней даты
  Color get todayColor => isDarkMode
      ? AppPallete.bluePrimary.withValues(alpha: 0.3)
      : AppPallete.blueLight;
}
