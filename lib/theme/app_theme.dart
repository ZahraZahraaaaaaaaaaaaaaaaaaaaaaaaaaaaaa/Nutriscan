import 'package:flutter/material.dart';

class AppTheme {
  // NutriScan Brand Colors
  static const Color primaryTheme = Color(0xFFB6465F); // Dominant brand color
  static const Color primaryButton = Color(0xFFDA9F93); // Primary button
  static const Color secondaryButton = Color(0xFFF2CCC3); // Secondary button
  static const Color supportingSurface =
      Color(0xFFEBD4CB); // UI surfaces & chips
  static const Color textDark = Color(0xFF121212); // Headings
  static const Color textBody = Color(0xFF2B2B2B); // Body text
  static const Color textWhite = Color(0xFFFFFFFF); // White text
  static const Color backgroundColor = Color(0xFFFFFFFF); // Background
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTheme,
        brightness: Brightness.light,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: backgroundColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryButton,
          foregroundColor: textWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTheme,
          side: const BorderSide(color: primaryTheme, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textDark,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          color: textDark,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textDark,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textBody,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textBody,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textBody,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          color: textBody,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textBody,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: supportingSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTheme, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundColor,
    );
  }
}
