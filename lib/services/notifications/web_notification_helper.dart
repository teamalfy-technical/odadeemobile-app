import 'dart:developer';
import 'web_notification_stub.dart'
    if (dart.library.html) 'web_notification_web.dart';

// Platform-agnostic interface for web notifications
Future<void> showWebNotification(String title, String body, String? imageUrl) async {
  try {
    await showWebNotificationImpl(title, body, imageUrl);
  } catch (e) {
    log('❌ Error showing web notification: $e');
  }
}
