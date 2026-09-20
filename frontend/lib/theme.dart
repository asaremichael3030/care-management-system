import 'package:flutter/material.dart';

// Shared colors and theme for the whole app.
class AppColors {
  static const Color primary = Color(0xFF0F5B5B);     // Deep teal
  static const Color primaryDark = Color(0xFF0A4242); // Darker teal
  static const Color accent = Color(0xFF2E8B8B);      // Light teal
  static const Color background = Color(0xFFF5F7F7);  // Soft grey
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}

// Builds the app-wide Material theme.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textDark,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(decoration: TextDecoration.none),
      ),
    ),
    // Stop the Flutter Web HTML renderer from underlining text on hover.
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}