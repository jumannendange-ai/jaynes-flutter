import 'package:flutter/material.dart';

class AppColors {
  // ─── Core ──────────────────────────────────────────────────────────────────
  static const bg       = Color(0xFF050508);
  static const bg2      = Color(0xFF0a0a0f);
  static const card     = Color(0xFF111118);
  static const card2    = Color(0xFF1a1a24);
  static const border   = Color(0xFF1e1e2e);

  // ─── Accent ────────────────────────────────────────────────────────────────
  static const red      = Color(0xFFE50914);   // Azam Max red
  static const redDark  = Color(0xFF8B0000);
  static const redGlow  = Color(0x33E50914);
  static const gold     = Color(0xFFFFD700);
  static const green    = Color(0xFF00C853);

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const text     = Color(0xFFFFFFFF);
  static const text2    = Color(0xFFB0B0C0);
  static const muted    = Color(0xFF555566);

  // ─── Live badge ────────────────────────────────────────────────────────────
  static const live     = Color(0xFFE50914);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.red,
    colorScheme: const ColorScheme.dark(
      primary:    AppColors.red,
      secondary:  AppColors.gold,
      surface:    AppColors.card,
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
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.red,
      unselectedItemColor: AppColors.muted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    ),
  );
}
