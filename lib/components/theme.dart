import 'package:flutter/material.dart';

import '../../constants.dart';

ThemeData theme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: odaBackground,
    fontFamily: "DMSans",
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: const ColorScheme.dark(
      primary: odaPrimary,
      secondary: odaSecondary,
      surface: odaCardBackground,
      background: odaBackground,
      onPrimary: Colors.white,
      onSecondary: odaBackground,
      onSurface: bodyText1,
      onBackground: bodyText1,
    ),
    cardTheme: const CardThemeData(
      color: odaCardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: odaPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: odaCardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: odaBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: odaBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: odaPrimary, width: 2),
      ),
      labelStyle: const TextStyle(color: bodyText2),
      hintStyle: const TextStyle(color: bodyText2),
    ),
  );
}

TextTheme textTheme() {
  return const TextTheme(
    displayLarge: TextStyle(color: bodyText1, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: bodyText1, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(color: bodyText1, fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(color: bodyText1, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: bodyText1, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(color: bodyText1, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(color: bodyText1, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: bodyText1, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: bodyText1, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: bodyText1),
    bodyMedium: TextStyle(color: bodyText1),
    bodySmall: TextStyle(color: bodyText2),
    labelLarge: TextStyle(color: bodyText1, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(color: bodyText1, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: bodyText2, fontWeight: FontWeight.w500),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    backgroundColor: odaBackground,
    foregroundColor: bodyText1,
    elevation: 0,
    iconTheme: IconThemeData(color: bodyText1),
    titleTextStyle: TextStyle(
      color: bodyText1,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: "DMSans",
    ),
  );
}
