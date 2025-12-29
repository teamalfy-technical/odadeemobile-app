import 'package:flutter/foundation.dart';

class PlatformHelper {
  static bool get isWeb => kIsWeb;

  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop => !kIsWeb && (
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux
  );
}
