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

/// Fixed artwork colors: the picture is "paper", so it looks the same in
/// both themes.
class ArtColors {
  ArtColors._();

  static const Color paper = Color(0xFFFFFFFF);
  static const Color line = Color(0xFF293241);
  static const Color tint = Color(0xFFFFF3B8);
  static const Color numberMuted = Color(0xFF9AA2B3);
  static const Color hint = Color(0xFF4D96FF);
}

/// UI colors that have no `ColorScheme` slot.
class AppExtraColors extends ThemeExtension<AppExtraColors> {
  const AppExtraColors({
    required this.green,
    required this.track,
    required this.dotGrid,
    required this.dashed,
    required this.handle,
    required this.lip,
    required this.darkButtonLip,
  });

  final Color green;
  final Color track;
  final Color dotGrid;
  final Color dashed;
  final Color handle;
  final Color lip;
  final Color darkButtonLip;

  static const light = AppExtraColors(
    green: AppColors.green,
    track: Color(0xFFFFF1C2),
    dotGrid: Color(0xFFF1E6C4),
    dashed: Color(0xFFD9D3C0),
    handle: Color(0xFFE3D9BC),
    lip: Color(0x24293241),
    darkButtonLip: Color(0xFF1A202B),
  );

  static const dark = AppExtraColors(
    green: AppDarkColors.green,
    track: AppDarkColors.surface2,
    dotGrid: AppDarkColors.border,
    dashed: AppDarkColors.border,
    handle: AppDarkColors.border,
    lip: Color(0x66000000),
    darkButtonLip: Color(0xFFD9D3C0),
  );

  @override
  AppExtraColors copyWith({
    Color? green,
    Color? track,
    Color? dotGrid,
    Color? dashed,
    Color? handle,
    Color? lip,
    Color? darkButtonLip,
  }) =>
      AppExtraColors(
        green: green ?? this.green,
        track: track ?? this.track,
        dotGrid: dotGrid ?? this.dotGrid,
        dashed: dashed ?? this.dashed,
        handle: handle ?? this.handle,
        lip: lip ?? this.lip,
        darkButtonLip: darkButtonLip ?? this.darkButtonLip,
      );

  @override
  AppExtraColors lerp(AppExtraColors? other, double t) {
    if (other == null) return this;
    return AppExtraColors(
      green: Color.lerp(green, other.green, t)!,
      track: Color.lerp(track, other.track, t)!,
      dotGrid: Color.lerp(dotGrid, other.dotGrid, t)!,
      dashed: Color.lerp(dashed, other.dashed, t)!,
      handle: Color.lerp(handle, other.handle, t)!,
      lip: Color.lerp(lip, other.lip, t)!,
      darkButtonLip: Color.lerp(darkButtonLip, other.darkButtonLip, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  AppExtraColors get extra => Theme.of(this).extension<AppExtraColors>()!;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Fredoka',
        extensions: const [AppExtraColors.light],
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
        fontFamily: 'Fredoka',
        extensions: const [AppExtraColors.dark],
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
