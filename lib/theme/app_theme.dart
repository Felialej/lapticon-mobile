import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF163A69);
  static const Color secondary = Color(0xFF2F80ED);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textPrimary = Color(0xFF182230);
  static const Color textSecondary = Color(0xFF667085);

  static ThemeData paraAutenticacion(ThemeData tema) {
    const borde = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFD0D5DD)),
    );

    return tema.copyWith(
      textTheme: tema.textTheme.copyWith(
        bodyLarge: const TextStyle(fontSize: 14, color: textPrimary),
        bodyMedium: const TextStyle(
          fontSize: 13.5,
          height: 1.4,
          color: Color(0xFF344054),
        ),
      ),
      inputDecorationTheme: const InputDecorationThemeData(
        filled: true,
        fillColor: Color(0xFFF9FAFB),
        hintStyle: TextStyle(color: Color(0xFF98A2B3)),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        constraints: BoxConstraints(minHeight: 54),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        errorMaxLines: 3,
        border: borde,
        enabledBorder: borde,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: secondary, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          textStyle: const TextStyle(
            fontSize: 13.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: primary,
        secondary: secondary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: secondary,
            width: 1.8,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}