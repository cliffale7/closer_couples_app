import 'package:flutter/material.dart';

/// Editorial palette for the development build.
/// Chapter artwork from the finished book is not available yet.
class CloserColors {
  static const midnight = Color(0xFF1B2430);
  static const ink = Color(0xFF241C18);
  static const ivory = Color(0xFFF6F1E7);
  static const parchment = Color(0xFFF3E6D0);
  static const card = Color(0xFFFFF9F1);
  static const line = Color(0xFFE4D5C3);
  static const copper = Color(0xFF8A4B32);
  static const copperSoft = Color(0xFFC4896A);
  static const teal = Color(0xFF2F5E5C);
  static const burgundy = Color(0xFF6E2E3A);
  static const nightCard = Color(0xFF243041);
}

ThemeData closerLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: CloserColors.ivory,
    colorScheme: const ColorScheme.light(
      primary: CloserColors.copper,
      onPrimary: CloserColors.ivory,
      secondary: CloserColors.teal,
      onSecondary: CloserColors.ivory,
      surface: CloserColors.card,
      onSurface: CloserColors.ink,
      error: CloserColors.burgundy,
      onError: CloserColors.ivory,
    ),
  );
  return base.copyWith(
    textTheme: _text(base.textTheme, CloserColors.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: CloserColors.ivory,
      foregroundColor: CloserColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: CloserColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: CloserColors.line),
      ),
    ),
    dividerColor: CloserColors.line,
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: CloserColors.card,
      indicatorColor: Color(0xFFE8D3C6),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: CloserColors.copper,
        foregroundColor: CloserColors.ivory,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CloserColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CloserColors.line),
      ),
    ),
  );
}

ThemeData closerDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CloserColors.midnight,
    colorScheme: const ColorScheme.dark(
      primary: CloserColors.copperSoft,
      onPrimary: Color(0xFF1B120E),
      secondary: Color(0xFF8FBFB8),
      onSecondary: CloserColors.midnight,
      surface: CloserColors.nightCard,
      onSurface: CloserColors.ivory,
      error: Color(0xFFE7B4BC),
      onError: CloserColors.midnight,
    ),
  );
  return base.copyWith(
    textTheme: _text(base.textTheme, CloserColors.ivory),
    appBarTheme: const AppBarTheme(
      backgroundColor: CloserColors.midnight,
      foregroundColor: CloserColors.ivory,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: CloserColors.nightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF3A4658)),
      ),
    ),
  );
}

TextTheme _text(TextTheme base, Color color) {
  TextStyle serif(TextStyle? style, FontWeight weight) {
    return (style ?? const TextStyle()).copyWith(
      fontFamily: 'serif',
      fontWeight: weight,
      color: color,
      height: 1.2,
    );
  }

  TextStyle sans(TextStyle? style) {
    return (style ?? const TextStyle()).copyWith(
      fontFamily: 'sans-serif',
      color: color,
      height: 1.45,
    );
  }

  return base.copyWith(
    headlineLarge: serif(base.headlineLarge, FontWeight.w600),
    headlineMedium: serif(base.headlineMedium, FontWeight.w600),
    headlineSmall: serif(base.headlineSmall, FontWeight.w600),
    titleLarge: serif(base.titleLarge, FontWeight.w600),
    titleMedium: sans(base.titleMedium),
    bodyLarge: sans(base.bodyLarge),
    bodyMedium: sans(base.bodyMedium),
    bodySmall: sans(base.bodySmall),
    labelLarge: sans(base.labelLarge),
  );
}

class ReaderPalette {
  const ReaderPalette({
    required this.background,
    required this.foreground,
    required this.muted,
  });

  final Color background;
  final Color foreground;
  final Color muted;

  static const parchment = ReaderPalette(
    background: Color(0xFFF3E6D0),
    foreground: Color(0xFF2A211C),
    muted: Color(0xFF6B5346),
  );
  static const night = ReaderPalette(
    background: Color(0xFF141A22),
    foreground: Color(0xFFF6F1E7),
    muted: Color(0xFFD7CBBA),
  );
  static const ink = ReaderPalette(
    background: Color(0xFFF7F4EE),
    foreground: Color(0xFF1C1916),
    muted: Color(0xFF5C534C),
  );

  static ReaderPalette named(String name) {
    switch (name) {
      case 'night':
        return night;
      case 'ink':
        return ink;
      default:
        return parchment;
    }
  }
}
