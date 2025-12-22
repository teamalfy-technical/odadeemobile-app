import 'dart:developer';

// Stub implementation for non-web platforms
Future<void> showWebNotificationImpl(String title, String body, String? imageUrl) async {
  log('⚠️ Web notifications not supported on this platform');
}
