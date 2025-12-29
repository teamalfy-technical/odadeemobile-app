import 'package:flutter/foundation.dart';

class PlatformHelper {
  static bool get isWeb => kIsWeb;
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
