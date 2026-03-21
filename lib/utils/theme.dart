import 'package:flutter/material.dart';

class AppColors {
  static const bg    = Color(0xFF0A0A0F);
  static const card  = Color(0xFF13131A);
  static const card2 = Color(0xFF1A1A24);
  static const red   = Color(0xFFE50914);
  static const text  = Color(0xFFFFFFFF);
  static const text2 = Color(0xFFB0B0C0);
  static const muted = Color(0xFF606070);
  static const gold  = Color(0xFFFFD700);
  static const green = Color(0xFF00C853);
  static const border= Color(0xFF2A2A35);
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bg,
  primaryColor: AppColors.red,
  colorScheme: const ColorScheme.dark(primary: AppColors.red, surface: AppColors.card),
  appBarTheme: const AppBarTheme(backgroundColor: AppColors.bg, elevation: 0,
    titleTextStyle: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800),
    iconTheme: IconThemeData(color: AppColors.text)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF0E0E16), selectedItemColor: AppColors.red,
    unselectedItemColor: AppColors.muted, type: BottomNavigationBarType.fixed),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, fillColor: AppColors.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
  elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.red, foregroundColor: Colors.white, elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
);
