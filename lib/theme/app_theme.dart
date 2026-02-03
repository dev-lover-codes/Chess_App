import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF769656),
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF769656),
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  // Chess board colors - 3D Wooden board style (like professional chess sets)
  static const Color lightSquare = Color(0xFFF0D9B5); // Creamy beige - lighter and warmer
  static const Color darkSquare = Color(0xFF7B4E2A); // Rich chocolate brown - darker and richer
  static const Color selectedSquare = Color(0xFFAAA23A); // Golden yellow highlight
  static const Color legalMoveIndicator = Color(0x80AAA23A); // Semi-transparent golden
  static const Color lastMoveHighlight = Color(0x80CDD26A); // Soft yellow-green highlight
  static const Color checkHighlight = Color(0x80FF6B6B); // Red for check

  // Dark mode chess board colors
  static const Color lightSquareDark = Color(0xFF4A4A4A);
  static const Color darkSquareDark = Color(0xFF2B2B2B);
  static const Color selectedSquareDark = Color(0xFF5A7A4A);
  static const Color legalMoveIndicatorDark = Color(0x805A7A4A);
  static const Color lastMoveHighlightDark = Color(0x809DB65A);
  static const Color checkHighlightDark = Color(0x80FF5555);
}
