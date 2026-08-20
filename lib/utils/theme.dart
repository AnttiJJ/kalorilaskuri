import 'package:flutter/material.dart';

final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF411d31),
  brightness: Brightness.dark,
);

final appTheme = ThemeData(
  colorScheme: colorScheme,

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.surface,
    ),
  ),

  cardTheme: CardThemeData(
    color: colorScheme.primaryContainer.withValues(alpha: 0.9),
  ),

  appBarTheme: AppBarThemeData(backgroundColor: colorScheme.surface),

  scaffoldBackgroundColor: Colors.transparent,

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: colorScheme.inversePrimary,
  ),
);
