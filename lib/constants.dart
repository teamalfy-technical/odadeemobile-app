import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:odadee/config/api_config.dart';
import 'package:odadee/services/auth_service.dart';

// Dark theme colors to match website
const odaPrimary = Color(0xff2563eb); // Blue accent
const odaSecondary = Color(0xfff4d03f); // Yellow accent
const odaBackground = Color(0xff0f172a); // Dark navy background
const odaCardBackground = Color(0xff1e293b); // Slightly lighter for cards
const odaBorder = Color(0xff334155); // Subtle borders
const odaLight = Color(0xff475569); // Light accents
const bodyText1 = Color(0xffffffff); // White text for dark theme
const bodyText2 = Color(0xffcbd5e1); // Light gray for secondary text

String get hostName => ApiConfig.baseUrl;
const socketHostName = "ws://api.odadee.net";

@Deprecated('Use AuthService().getAccessToken() instead - tokens are now in secure storage')
Future<String?> getApiPref() async {
  final authService = AuthService();
  return await authService.getAccessToken();
}






Future<String?> getUserYearGroup() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("YearGroup");
}

Future<String?> getUserImage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("image");
}


Future<String?> getUserIDPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("USER_ID");
}





class PasteTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow pasting of text by returning the new value unchanged
    return newValue;
  }
}



Map<int, String> monthNames = {
  1: "January",
  2: "February",
  3: "March",
  4: "April",
  5: "May",
  6: "June",
  7: "July",
  8: "August",
  9: "September",
  10: "October",
  11: "November",
  12: "December",
};


Map<String, dynamic> extractDateInfo(String dateString) {
  try {
    // Handle various date formats
    DateTime dateTime;
    
    // Try parsing as ISO 8601 first
    try {
      dateTime = DateTime.parse(dateString);
    } catch (e) {
      // If that fails, try the old space-separated format
      List<String> parts = dateString.split(' ');
      String datePart = parts[0];
      List<String> dateComponents = datePart.split('-');
      
      if (dateComponents.length < 3) {
        throw FormatException('Invalid date format: $dateString');
      }
      
      int year = int.parse(dateComponents[0]);
      int month = int.parse(dateComponents[1]);
      int day = int.parse(dateComponents[2]);
      dateTime = DateTime(year, month, day);
    }
    
    String? monthInWords = monthNames[dateTime.month];
    
    return {
      'day': dateTime.day,
      'month': monthInWords ?? 'Unknown',
      'year': dateTime.year,
    };
  } catch (e) {
    // Return default values if parsing fails - keep types consistent
    print('Date parsing error for "$dateString": $e');
    return {
      'day': 1,
      'month': 'TBA',
      'year': 2024,
    };
  }
}



String convertToFormattedDate(String dateString) {
  final dateTime = DateTime.parse(dateString);
  final month = DateFormat.MMM().format(dateTime);
  final day = DateFormat.d().format(dateTime);
  final year = DateFormat.y().format(dateTime);

  return "$month $day, $year";
}

