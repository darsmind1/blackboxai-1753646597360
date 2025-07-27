import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(
        StyleConstants.primaryColor,
        <int, Color>{
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(0xFF42A5F5),
          500: Color(StyleConstants.primaryColor),
          600: Color(0xFF1E88E5),
          700: Color(0xFF1976D2),
          800: Color(0xFF1565C0),
          900: Color(0xFF0D47A1),
        },
      ),
      
      // Background colors
      scaffoldBackgroundColor: Color(StyleConstants.backgroundColor),
      backgroundColor: Color(StyleConstants.backgroundColor),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Color(StyleConstants.backgroundColor),
        foregroundColor: Color(StyleConstants.textPrimary),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: Color(StyleConstants.textPrimary),
        ),
      ),
      
      // Text theme - Arial very small fonts
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: Color(StyleConstants.textPrimary),
        ),
        displayMedium: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeMedium,
          fontWeight: FontWeight.w500,
          color: Color(StyleConstants.textPrimary),
        ),
        displaySmall: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeSmall,
          fontWeight: FontWeight.w400,
          color: Color(StyleConstants.textPrimary),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeSmall,
          fontWeight: FontWeight.w400,
          color: Color(StyleConstants.textPrimary),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeVerySmall,
          fontWeight: FontWeight.w400,
          color: Color(StyleConstants.textSecondary),
        ),
        labelLarge: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeSmall,
          fontWeight: FontWeight.w500,
          color: Color(StyleConstants.textPrimary),
        ),
      ),
      
      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(StyleConstants.primaryColor),
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeSmall,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: StyleConstants.spacingMedium,
            vertical: StyleConstants.spacingSmall,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Color(StyleConstants.textSecondary)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Color(StyleConstants.primaryColor)),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeSmall,
          color: Color(StyleConstants.textSecondary),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Arial',
          fontSize: StyleConstants.fontSizeVerySmall,
          color: Color(StyleConstants.textSecondary),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: StyleConstants.spacingMedium,
          vertical: StyleConstants.spacingSmall,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: Color(StyleConstants.surfaceColor),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: StyleConstants.spacingSmall,
          vertical: StyleConstants.spacingXSmall,
        ),
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: Color(StyleConstants.textSecondary),
        size: 20,
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(StyleConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}
