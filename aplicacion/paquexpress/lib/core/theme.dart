import 'package:flutter/material.dart';

class AppTheme {
  static const Color kPrimaryColor = Color(0xFF1E1E2C); // Oscuro elegante
  static const Color kAccentColor = Color(0xFFFF6B6B);  // Naranja/Coral vibrante
  static const Color kSurfaceColor = Colors.white;
  static const double kBorderRadius = 20.0;

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: Color(0xFFF4F6F8), // Fondo gris claro como el original
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
    useMaterial3: true,
    fontFamily: 'Roboto',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor, // Botones azul oscuro
        foregroundColor: Colors.white,
        elevation: 5,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius)
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100, // Campos gris claro como el original
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        borderSide: BorderSide.none,
      ),
      prefixIconColor: kPrimaryColor,
    ),
  );
}