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

  /// Get light theme
  ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF2563eb),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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
        backgroundColor: Color(0xFF2563eb),
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey[300],
    );
  }

  /// Get dark theme
  ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF2563eb),
      scaffoldBackgroundColor: Color(0xFF0f172a),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1e293b),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Color(0xFF94a3b8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1e293b),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF334155)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2563eb),
      ),
      cardColor: Color(0xFF1e293b),
      dividerColor: Color(0xFF334155),
    );
  }

  /// Initialize theme from saved preference
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

  /// Toggle theme between light and dark
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreference();
    notifyListeners();
  }

  /// Set theme mode explicitly
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _saveThemePreference();
      notifyListeners();
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  /// Get current active theme
  ThemeData getCurrentTheme() {
    return _isDarkMode ? getDarkTheme() : getLightTheme();
  }
}
