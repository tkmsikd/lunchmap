import 'package:flutter/material.dart';

/// Theme constants for the application
class ThemeConstants {
  // Primary colors
  static const Color primaryColor = Color(0xFF3F51B5); // Indigo
  static const Color primaryLightColor = Color(0xFF757DE8);
  static const Color primaryDarkColor = Color(0xFF002984);

  // Secondary colors
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color secondaryLightColor = Color(0xFFFFC947);
  static const Color secondaryDarkColor = Color(0xFFC66900);

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;

  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textOnPrimaryColor = Colors.white;
  static const Color textOnSecondaryColor = Colors.black;

  // Error colors
  static const Color errorColor = Color(0xFFB00020);

  // Success colors
  static const Color successColor = Color(0xFF4CAF50);

  // Rating colors
  static const Color ratingColor = Color(0xFFFFC107); // Amber

  // Category colors
  static const Map<String, Color> categoryColors = {
    '和食': Color(0xFFE57373), // Red
    '洋食': Color(0xFF64B5F6), // Blue
    '中華': Color(0xFFFFB74D), // Orange
    'イタリアン': Color(0xFF81C784), // Green
    'フレンチ': Color(0xFF9575CD), // Purple
    'カフェ': Color(0xFFFFD54F), // Amber
    'ファストフード': Color(0xFFF06292), // Pink
    'ラーメン': Color(0xFF4DD0E1), // Cyan
    '韓国料理': Color(0xFFAED581), // Light Green
    'その他': Color(0xFFB0BEC5), // Blue Grey
  };

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeExtraLarge = 24.0;
  static const double fontSizeHuge = 32.0;

  // Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevationRegular = 4.0;
  static const double elevationLarge = 8.0;

  // Create the light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: textOnPrimaryColor,
        secondary: secondaryColor,
        onSecondary: textOnSecondaryColor,
        error: errorColor,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: textPrimaryColor,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimaryColor,
        elevation: elevationSmall,
      ),
      cardTheme: const CardTheme(
        color: surfaceColor,
        elevation: elevationSmall,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeHuge,
          fontWeight: fontWeightBold,
          color: textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeExtraLarge,
          fontWeight: fontWeightBold,
          color: textPrimaryColor,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeLarge,
          fontWeight: fontWeightMedium,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: fontWeightMedium,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeRegular,
          fontWeight: fontWeightRegular,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeRegular,
          fontWeight: fontWeightRegular,
          color: textSecondaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
    );
  }

  // Create the dark theme (for future implementation)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryLightColor,
        onPrimary: Colors.black,
        secondary: secondaryLightColor,
        onSecondary: Colors.black,
        error: Color(0xFFCF6679),
        onError: Colors.black,
        background: Color(0xFF121212),
        onBackground: Colors.white,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
      // Additional dark theme settings would be defined here
    );
  }
}
