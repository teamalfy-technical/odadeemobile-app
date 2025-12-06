import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();

  bool _isDarkMode = true;
  static const String _themePreferenceKey = 'isDarkMode';

  ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  bool get isDarkMode => _isDarkMode;

  static const Color primaryBlue = Color(0xFF2563eb);
  static const Color secondaryYellow = Color(0xFFf4d03f);
  static const Color successGreen = Color(0xFF10b981);

  ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryYellow,
        surface: Colors.white,
        surfaceContainer: Colors.grey[50]!,
        surfaceContainerHighest: Colors.grey[100]!,
        onSurface: Colors.black87,
        onSurfaceVariant: Colors.grey[600]!,
        outline: Colors.grey[300]!,
        outlineVariant: Colors.grey[400]!,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        headlineLarge:
            TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.grey[600]),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
      ),
      cardColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: Colors.grey[300],
      dialogBackgroundColor: Colors.white,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
      ),
    );
  }

  ThemeData getDarkTheme() {
    const darkBackground = Color(0xFF0f172a);
    const darkSurface = Color(0xFF1e293b);
    const darkBorder = Color(0xFF334155);
    const darkTextPrimary = Colors.white;
    const darkTextSecondary = Color(0xFF94a3b8);
    const darkTextMuted = Color(0xFF64748b);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        secondary: secondaryYellow,
        surface: darkSurface,
        surfaceContainerHighest: darkBackground,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
        outlineVariant: darkTextMuted,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        headlineLarge:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: darkTextPrimary),
        bodySmall: TextStyle(color: darkTextSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkBorder),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
      ),
      cardColor: darkSurface,
      cardTheme: CardThemeData(
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: darkBorder,
      dialogBackgroundColor: darkSurface,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
      ),
    );
  }

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themePreferenceKey) ?? true;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
      _isDarkMode = true;
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreference();
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _saveThemePreference();
      notifyListeners();
    }
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  ThemeData getCurrentTheme() {
    return _isDarkMode ? getDarkTheme() : getLightTheme();
  }
}

class AppColors {
  static Color cardColor(BuildContext context) => Theme.of(context).cardColor;
  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;
  static Color textColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color subtitleColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  static Color mutedColor(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;
  static Color borderColor(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static const Color success = Color(0xFF10b981);
  static const Color error = Color(0xFFef4444);
  static const Color warning = Color(0xFFf59e0b);

  static Color onPrimary(BuildContext context) => Colors.white;
}
