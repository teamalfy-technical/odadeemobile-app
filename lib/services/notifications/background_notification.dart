import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:odadee/firebase_options.dart';
import 'package:odadee/services/notifications/notification_controller.dart';


/// Background message handler - runs in separate isolate
/// This allows instantNotification() to download and display images even when app is backgrounded
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in the background isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    log('Background notification received: ${message.notification?.body}');
    log('Message title: ${message.notification?.title}');
    log('Message data: ${message.data}');

    final data = message.data;

    // iOS: Only create local notification if there's NO notification field (data-only)
    // This prevents duplicates when notification field is present
    if (Platform.isIOS && data.containsKey('title') && data.containsKey('body')) {
      if (message.notification == null) {
        // Data-only notification - create local notification with image
        final payload = jsonEncode({
          'payload': {
            'title': data['title'] ?? 'Alert',
            'description': data['body'] ?? 'Welcome back',
            'image_url': data['image_url'],
            "only_image":data['only_image'] ?? false,
          },
        });

        await instantNotification(
          data['body'],
          data['title'],
          payload,
          imageUrl: data['image_url'],
        );

        log('iOS: Local notification created (data-only message)');
      } else {
        log('iOS: Skipping local notification (system already showing it)');
      }
    } else if (Platform.isAndroid) {
      log('Android: System handles notification, getInitialMessage will capture tap');
    } else {
      log('Background notification missing title or body in data');
    }
  } catch (e) {
    log("Background notification error: ${e.toString()}");
  }
}