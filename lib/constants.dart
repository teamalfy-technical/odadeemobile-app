import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

const odaPrimary = Color(0xff0017D7);
const odaSecondary = Color(0xffBD8D43);
const odaBorder = Color(0xffE3EEF4);
const odaLight = Color(0xffd0bcd5);
const bodyText1 = Color(0xff515459);
const bodyText2 = Color(0x8E515459);


const hostName = "http://api.odadee.net";
const socketHostName = "ws://api.odadee.net";


Future<String?> getApiPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("API_Key");
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
  List<String> parts = dateString.split(' ');
  String datePart = parts[0];
  List<String> dateComponents = datePart.split('-');

  int year = int.parse(dateComponents[0]);
  int month = int.parse(dateComponents[1]);
  int day = int.parse(dateComponents[2]);
  String? monthInWords = monthNames[month];

  return {
    'day': day,
    'month': monthInWords,
    'year': year,
  };
}



String convertToFormattedDate(String dateString) {
  final dateTime = DateTime.parse(dateString);
  final month = DateFormat.MMM().format(dateTime);
  final day = DateFormat.d().format(dateTime);
  final year = DateFormat.y().format(dateTime);

  return "$month $day, $year";
}

