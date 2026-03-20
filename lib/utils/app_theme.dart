import 'package:flutter/material.dart';

class AppColors {
  static const bg      = Color(0xFF060610);
  static const card    = Color(0xFF0f0f22);
  static const card2   = Color(0xFF0c0c1e);
  static const accent  = Color(0xFF00d4ff);
  static const accent2 = Color(0xFFff4466);
  static const gold    = Color(0xFFffd700);
  static const green   = Color(0xFF00ff88);
  static const muted   = Color(0xFF4a5568);
  static const text    = Color(0xFFe8eaf6);
  static const border  = Color(0xFF1a2040);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.accent,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.accent,
      secondary: AppColors.accent2,
      surface:   AppColors.card,
      background: AppColors.bg,
    ),
    cardColor: AppColors.card,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.muted,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
    ),
  );
}
