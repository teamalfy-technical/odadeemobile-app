import 'dart:html' as html;
import 'dart:developer';

// Web implementation using dart:html
Future<void> showWebNotificationImpl(String title, String body, String? imageUrl) async {
  try {
    // Check if Notification API is supported
    if (html.Notification.supported == false) {
      log('❌ Notification API not supported in this browser');
      return;
    }

    // Request permission if not granted
    String permission = html.Notification.permission ?? "";

    if (permission == 'default') {
      permission = await html.Notification.requestPermission();
    }

    if (permission != 'granted') {
      log('⚠️ Notification permission not granted: $permission');
      return;
    }

    // Create notification
    final notification = html.Notification(
      title,
      body: body,
      icon: imageUrl ?? '/icons/ic_launcher.png',
      tag: 'odadee-notification',
    );

    // Auto-close after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      try {
        notification.close();
      } catch (e) {
        // Notification might already be closed
      }
    });

    log('✅ Web notification shown: $title');
  } catch (e) {
    log('❌ Error in showWebNotificationImpl: $e');
    rethrow;
  }
}
