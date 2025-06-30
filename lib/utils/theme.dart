import 'package:flutter/material.dart';

class AppTheme {
  // McAfee Brand Colors
  static const Color mcafeeRed = Color(0xFFE31E24);
  static const Color mcafeeBlue = Color(0xFF0078D4);
  static const Color mcafeeDarkBlue = Color(0xFF003366);
  static const Color safeGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color dangerRed = Color(0xFFE31E24);
  
  // Security Status Colors
  static const Color criticalThreat = Color(0xFFD32F2F);
  static const Color highThreat = Color(0xFFE31E24);
  static const Color mediumThreat = Color(0xFFFF9800);
  static const Color lowThreat = Color(0xFFFFC107);
  static const Color noThreat = Color(0xFF4CAF50);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mcafeeRed,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: mcafeeDarkBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mcafeeRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mcafeeRed, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mcafeeRed,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: mcafeeDarkBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mcafeeRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static Color getThreatColor(double threatLevel) {
    if (threatLevel >= 0.9) return criticalThreat;
    if (threatLevel >= 0.7) return highThreat;
    if (threatLevel >= 0.5) return mediumThreat;
    if (threatLevel >= 0.3) return lowThreat;
    return noThreat;
  }

  static String getThreatDescription(double threatLevel) {
    if (threatLevel >= 0.9) return 'Critical Threat';
    if (threatLevel >= 0.7) return 'High Threat';
    if (threatLevel >= 0.5) return 'Medium Threat';
    if (threatLevel >= 0.3) return 'Low Threat';
    return 'Safe';
  }
}