import 'package:flutter/material.dart';

/// Brand colours from the web app (theme-color #0E7C86, teal primary).
const waslPrimary = Color(0xFF0E7C86);
const waslAccent = Color(0xFF2F7E78);

ThemeData waslTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: waslPrimary, primary: waslPrimary);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Tajawal',
    scaffoldBackgroundColor: const Color(0xFFF7FAF9),
    appBarTheme: AppBarTheme(backgroundColor: scheme.primary, foregroundColor: Colors.white, centerTitle: true),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
    inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
    cardTheme: CardThemeData(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: Colors.white),
  );
}
