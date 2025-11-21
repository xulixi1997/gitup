import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF3E2723);
  static const Color secondary = Color(0xFF5D4037);
  static const Color accent = Color(0xFFFF9800);
  static const Color background = Color(0xFF261C19);
  static const Color surface = Color(0xFF3E2723);

  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textSub = Color(0xFFBCAAA4);
  static const Color textDisabled = Color(0xFF8D6E63);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: textMain,
        onSecondary: textMain,
        onSurface: textMain,
        error: Colors.redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: textMain),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textMain),
        bodyMedium: TextStyle(color: textSub),
        labelLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: textMain,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xE6261C19),
        selectedItemColor: accent,
        unselectedItemColor: textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
