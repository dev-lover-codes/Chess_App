import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Design Colors
  static const Color primaryPurple = Color(0xFF8B5CF6); // Violet
  static const Color secondaryPink = Color(0xFFEC4899); // Pink
  static const Color darkBackground = Color(0xFF0F0F0F); // Almost black
  static const Color cardSurface = Color(0xFF1E1E1E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9F5AFD), Color(0xFFE990D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white10, Colors.white05],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.outfitTextTheme(), // More modern than Inter for this look
    scaffoldBackgroundColor: Colors.white,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.dark,
      background: darkBackground,
      surface: cardSurface,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
    ),
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
  );

  // Chess board colors
  static const Color lightSquare = Color(0xFFF0D9B5);
  static const Color darkSquare = Color(0xFF7B4E2A);
  static const Color selectedSquare = Color(0xFFAAA23A);
  static const Color legalMoveIndicator = Color(0x80AAA23A);
  static const Color lastMoveHighlight = Color(0x80CDD26A);
  static const Color checkHighlight = Color(0x80FF6B6B);

  static const Color lightSquareDark = Color(0xFF4A4A4A);
  static const Color darkSquareDark = Color(0xFF2B2B2B);
  static const Color selectedSquareDark = Color(0xFF5A7A4A);
  static const Color legalMoveIndicatorDark = Color(0x805A7A4A);
  static const Color lastMoveHighlightDark = Color(0x809DB65A);
  static const Color checkHighlightDark = Color(0x80FF5555);
}
