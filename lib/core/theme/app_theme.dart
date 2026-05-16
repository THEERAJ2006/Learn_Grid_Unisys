import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF1A3A5C);
  static const accentColor = Color(0xFF0D9AE0);
  static const backgroundColor = Color(0xFF0D1B2A);
  static const surfaceColor = Color(0xFF1A2540);
  static const successColor = Color(0xFF06A77D);
  static const warningColor = Color(0xFFE85D04);
  static const errorColor = Color(0xFFE74C3C);

  // Short aliases used by feature screens.
  static const primary = primaryColor;
  static const accent = accentColor;
  static const background = backgroundColor;
  static const surface = surfaceColor;
  static const success = successColor;
  static const warning = warningColor;
  
  // Text colors
  static const textPrimary = Color(0xFFFFFFFF);  // White for dark theme
  static const textSecondary = Color(0xFFB0B8C1);  // Light gray
  
  // Surface variants
  static const surfaceVariant = Color(0xFF253346);  // Darker surface for cards

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black54,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: Colors.white,
      error: errorColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: accentColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: accentColor,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: accentColor,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: accentColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white54,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: accentColor,
      secondary: primaryColor,
      surface: surfaceColor,
      error: errorColor,
    ),
  );
}
