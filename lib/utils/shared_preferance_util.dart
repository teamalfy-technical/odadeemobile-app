import 'package:shared_preferences/shared_preferences.dart';


class SharedPreferencesUtils {
  static late SharedPreferences _prefs;

  static set prefs(SharedPreferences prefs) => _prefs = prefs;

  static SharedPreferences get instance => _prefs;

  static String fcm_token = 'fcm_token';

  static setFcmToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(fcm_token, token);
  }

  static getFcmToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(fcm_token);
  }

}
