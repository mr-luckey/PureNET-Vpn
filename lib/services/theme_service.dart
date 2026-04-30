import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/pref.dart';

class AppTheme {
  // Blue Color Family
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightBlue = Color(0xFF0066CC);
  static const Color darkBlue = Color(0xFF003380);
  static const Color accentBlue = Color(0xFF3399FF);
  static const Color lightAccentBlue = Color(0xFF66B3FF);
  static const Color veryLightBlue = Color(0xFFE6F2FF);
  
  // Status Colors
  static const Color connectedGreen = Color(0xFF00C853);
  static const Color disconnectedWhite = Colors.white;
  static const Color connectingOrange = Color(0xFFFF9800);
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3D9FF);
  static const Color textDark = Color(0xFF1A1A1A);
  
  // Background Colors
  static const Color backgroundPrimary = Color(0xFF004AAD);
  static const Color backgroundSecondary = Color(0xFF003380);
  static const Color cardBackground = Color(0xFF0052CC);
  
  // Get Comfortaa Text Style
  static TextStyle comfortaaTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.comfortaa(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundPrimary,
      fontFamily: GoogleFonts.comfortaa().fontFamily,
      textTheme: TextTheme(
        displayLarge: comfortaaTextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: comfortaaTextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: comfortaaTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: comfortaaTextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: comfortaaTextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: comfortaaTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: comfortaaTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: comfortaaTextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: comfortaaTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: comfortaaTextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: comfortaaTextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: comfortaaTextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: comfortaaTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: comfortaaTextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: comfortaaTextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundPrimary,
        foregroundColor: textPrimary,
        titleTextStyle: comfortaaTextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: textPrimary,
          textStyle: comfortaaTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundSecondary,
      fontFamily: GoogleFonts.comfortaa().fontFamily,
      textTheme: TextTheme(
        displayLarge: comfortaaTextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: comfortaaTextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: comfortaaTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: comfortaaTextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: comfortaaTextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: comfortaaTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: comfortaaTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: comfortaaTextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: comfortaaTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: comfortaaTextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: comfortaaTextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: comfortaaTextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: comfortaaTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: comfortaaTextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: comfortaaTextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundSecondary,
        foregroundColor: textPrimary,
        titleTextStyle: comfortaaTextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: textPrimary,
          textStyle: comfortaaTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
  
  // Get current theme based on preference
  static ThemeData get currentTheme {
    return Pref.isDarkMode ? darkTheme : lightTheme;
  }
}

