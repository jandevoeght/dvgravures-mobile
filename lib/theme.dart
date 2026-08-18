import 'package:flutter/material.dart';

const dvDarkBlue = Color(0xFF123F78);
const dvMidBlue = Color(0xFF236FB8);
const dvBrightBlue = Color(0xFF2F7FE5);
const dvLightBlue = Color(0xFFEEF6FF);
const dvSoftBlue = Color(0xFFDCEcff);

ThemeData buildDvTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: dvDarkBlue,
    onPrimary: Colors.white,
    secondary: dvMidBlue,
    onSecondary: Colors.white,
    error: Color(0xFFB3261E),
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Color(0xFF1E2B38),
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: dvLightBlue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: dvDarkBlue,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: dvSoftBlue,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected) ? dvDarkBlue : const Color(0xFF5A6670),
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? dvDarkBlue : const Color(0xFF5A6670),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFDCE6EF)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dvBrightBlue, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: dvDarkBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: dvDarkBlue,
      foregroundColor: Colors.white,
    ),
  );
}
