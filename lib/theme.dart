import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFFD93D);
  static const Color primaryDark = Color(0xFFF4B942);

  static const Color secondary = Color(0xFF4D96FF);

  static const Color pink = Color(0xFFFF6B9D);
  static const Color green = Color(0xFF6BCB77);
  static const Color orange = Color(0xFFFF8C42);
  static const Color purple = Color(0xFF9B7EDE);

  static const Color background = Color(0xFFFFF9E8);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color text = Color(0xFF293241);
  static const Color textMuted = Color(0xFF7A8499);
}

/// Dark-theme palette. Separate scale (not just dimmed light colors):
/// brightened brand hues for contrast on violet-tinted dark surfaces.
class AppDarkColors {
  AppDarkColors._();

  static const Color primary = Color(0xFFFFE066);
  static const Color primaryDark = Color(0xFFFFC857);

  static const Color secondary = Color(0xFF6EA8FF);

  static const Color pink = Color(0xFFFF78A8);
  static const Color green = Color(0xFF72D982);
  static const Color orange = Color(0xFFFF9B5A);
  static const Color purple = Color(0xFFB197F0);

  static const Color background = Color(0xFF17152A);
  static const Color surface = Color(0xFF24213A);
  static const Color surface2 = Color(0xFF302B4A);

  static const Color text = Color(0xFFFFF9E8);
  static const Color textMuted = Color(0xFFB8B3C9);
  static const Color border = Color(0xFF403A5C);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.text,
          primaryContainer: AppColors.primaryDark,
          onPrimaryContainer: AppColors.text,
          secondary: AppColors.secondary,
          onSecondary: AppColors.surface,
          secondaryContainer: AppColors.purple,
          onSecondaryContainer: AppColors.surface,
          tertiary: AppColors.pink,
          onTertiary: AppColors.surface,
          tertiaryContainer: AppColors.orange,
          onTertiaryContainer: AppColors.text,
          error: AppColors.pink,
          onError: AppColors.surface,
          surface: AppColors.surface,
          onSurface: AppColors.text,
          surfaceContainerHighest: AppColors.background,
          onSurfaceVariant: AppColors.textMuted,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.text,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.surface,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.text),
          bodySmall: TextStyle(color: AppColors.textMuted),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppDarkColors.primary,
          onPrimary: AppDarkColors.background,
          primaryContainer: AppDarkColors.primaryDark,
          onPrimaryContainer: AppDarkColors.background,
          secondary: AppDarkColors.secondary,
          onSecondary: AppDarkColors.background,
          secondaryContainer: AppDarkColors.purple,
          onSecondaryContainer: AppDarkColors.background,
          tertiary: AppDarkColors.pink,
          onTertiary: AppDarkColors.background,
          tertiaryContainer: AppDarkColors.orange,
          onTertiaryContainer: AppDarkColors.background,
          error: AppDarkColors.pink,
          onError: AppDarkColors.background,
          surface: AppDarkColors.surface,
          onSurface: AppDarkColors.text,
          surfaceContainerHighest: AppDarkColors.surface2,
          onSurfaceVariant: AppDarkColors.textMuted,
          outlineVariant: AppDarkColors.border,
        ),
        scaffoldBackgroundColor: AppDarkColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppDarkColors.surface,
          foregroundColor: AppDarkColors.text,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppDarkColors.secondary,
          foregroundColor: AppDarkColors.background,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppDarkColors.text),
          bodySmall: TextStyle(color: AppDarkColors.textMuted),
        ),
      );
}
