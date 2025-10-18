import 'package:flutter/material.dart';

// Custom color extension for stat items
class CustomColors extends ThemeExtension<CustomColors> {
  final Color statTeal;

  const CustomColors({required this.statTeal});

  @override
  CustomColors copyWith({Color? statTeal}) {
    return CustomColors(statTeal: statTeal ?? this.statTeal);
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      statTeal: Color.lerp(statTeal, other.statTeal, t) ?? statTeal,
    );
  }
}

final ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF34656D), // Teal
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFAEAB1), // Soft yellow
    onPrimaryContainer: Color(0xFF334443), // Deep teal/green
    secondary: Color(0xFF334443), // Deep teal/green
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFAF8F1), // Very light beige/white
    onSecondaryContainer: Color(0xFF34656D), // Teal
    background: Color(0xFFFAF8F1), // Very light beige/white
    onBackground: Color(0xFF334443), // Deep teal/green
    surface: Color(0xFFFFFFFF), // White
    onSurface: Color(0xFF334443), // Deep teal/green
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFFAF8F1),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF34656D),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF34656D),
    foregroundColor: Colors.white,
  ),
  cardTheme: const CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    color: Color(0xFFFAEAB1), // Soft yellow for cards
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF334443)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF334443)),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF34656D)),
  ),
  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(statTeal: Color(0xFF34656D)),
  ],
);

final ThemeData appDarkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
    primary: Colors.white, // Teal
    primaryContainer: Colors.teal[400]!,
    onPrimaryContainer: Colors.white,
    onSecondaryContainer: Colors.white,
    onSurface: Colors.white,
  ),
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(statTeal: Color(0xFF26A69A)), // Teal[400] for dark
  ],
);
