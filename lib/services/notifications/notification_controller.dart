import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/constants.dart';
import 'package:odadee/navigation_service.dart';
import 'package:odadee/services/notifications/notification_actions_manager.dart';
import 'package:odadee/utils/shared_preferance_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:odadee/utils/platform_helper.dart';



class NotificationController{
  NotificationController();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Static subscription to prevent duplicate listener registration
  static StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  /// Wait for navigation context to be available with retry mechanism
  /// This is especially important on Android when app is launched from killed state
  Future<void> _waitForNavigationContext({int maxRetries = 10}) async {
    int retries = 0;
    while (NavigationService.navigatorKey.currentContext == null && retries < maxRetries) {
      log('⏳ Waiting for navigation context... (attempt ${retries + 1}/$maxRetries)');
      await Future.delayed(Duration(milliseconds: 200));
      retries++;
    }
    if (NavigationService.navigatorKey.currentContext != null) {
      log('✅ Navigation context is now available');
    }
  }
  Future initialise({bool showInitialNotification = true, bool listenNotification = true}) async{
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('User granted permission: ${settings.authorizationStatus}');
    try{
      await _fcm.subscribeToTopic("topic");
    }catch(e){}

    if(showInitialNotification == true){
      log('🔍 Checking for initial message (app opened from notification)...');
      // Android needs more time to get intent data when app is killed
      final delayDuration = PlatformHelper.isAndroid ? Duration(milliseconds: 1500) : Duration(milliseconds: 500);

      Future.delayed(delayDuration, () async {
        try {
          log('⏰ getInitialMessage delay completed (${delayDuration.inMilliseconds}ms), now checking...');
          final initialMessage = await _fcm.getInitialMessage();
          if (initialMessage != null) {
            log('======Message clicked to opened getInitialMessage============${initialMessage}');
            log('Initial message data: ${initialMessage.data}');
            log('Platform: ${Platform.operatingSystem}');

            // Wait for navigation context to be available with retry mechanism
            await _waitForNavigationContext();

            if (NavigationService.navigatorKey.currentContext != null) {
              NotificationsActionsManager? _notificationsActionsManager;
              _notificationsActionsManager = NotificationsActionsManager.getInstance(NavigationService.navigatorKey.currentContext!);
              final data = initialMessage.data;
              if (data.containsKey('title') && data.containsKey('body')){
                await  _notificationsActionsManager!.performAction(varag: {
                  "payload":{
                    "title":data['title'] ?? "Alert",
                    "description":data['body']  ?? "Welcome back",
                    "image_url":data['image_url'] ,
                    "only_image":data['only_image'] ?? false,
                  }
                });
                log('✅ Initial notification action performed successfully');
              }
            } else {
              log('⚠️ Navigation context not available after retries');
            }
          } else {
            log('No initial message found (app not opened from notification)');
          }
        } catch (e) {
          log('Error handling initial message: ${e.toString()}');
        }
      });
    }

   if(listenNotification == true){
     // Cancel existing subscriptions to prevent duplicates
     await _foregroundMessageSubscription?.cancel();
     await _onMessageOpenedAppSubscription?.cancel();
     log("✅ Registering foreground listeners (canceling any previous ones)");

     _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
       try{
         log('🔔 FOREGROUND LISTENER TRIGGERED');
         print('Received foreground message: ${message.notification?.body}');
         print('Message title: ${message.notification?.title}');
         print('Message data: ${message.data}');
         final data = message.data;
         if (data.containsKey('title') && data.containsKey('body')) {
           final payload = jsonEncode({
             'payload': {
               'title':  data['title'] ?? 'Alert',
               'description':  data['body'] ?? 'Welcome back',
               'image_url':  data['image_url'],
               "only_image":data['only_image'] ?? false,
             },
           });
           await instantNotification(
             data['body'],
             data['title'],
             payload,
             imageUrl: data['image_url'],
           );
         }
       }catch(e){
         log("notification error message2:${e.toString()}");
       }
     });

     _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
       print('Got a message whilst in the onlunch!');
       log('Message data2: notificationCount: ${message.notification?.apple?.imageUrl}');
       print('Message data2: ${message.data}');
       NotificationsActionsManager? _notificationsActionsManager;
       _notificationsActionsManager = NotificationsActionsManager.getInstance(NavigationService.navigatorKey.currentContext!);
       final data = message.data;
       if (data.containsKey('title') && data.containsKey('body')){
         await  _notificationsActionsManager!.performAction(varag: {
           "payload":{
             "title":data['title'] ?? "Alert",
             "description":data['body']  ?? "Welcome back",
             "image_url":data['image_url'] ,
             "only_image":data['only_image'] ?? false,

           }
         });
       }
     });
   }

    await getDeviceFcmToken();
  }

getDeviceFcmToken(){
  if(PlatformHelper.isWeb){
    // For web, you need to provide VAPID key from Firebase Console
    // Go to Project Settings > Cloud Messaging > Web Push certificates
    // TODO: Replace with your actual VAPID key
    _fcm.getToken(
      vapidKey: 'GGQLIJKj-bV19HNkdOrLmIrJMij5gEYrJ_xNoQ78fhU',
    ).then((String? token) async{
      log("Web FCM token: $token");
      await SharedPreferencesUtils.setFcmToken(token ?? "");
    }).catchError((e){
      log("Error getting web FCM token: ${e.toString()}");
    });
  }
  else if(PlatformHelper.isIOS){
    try{
      _fcm.getToken().then((String? token) async{
        log("iOS FCM token: $token");
        await SharedPreferencesUtils.setFcmToken(token ?? "");
      });
    }catch(e){
      print("Error getting iOS token: ${e.toString()}");
      _fcm.getAPNSToken().then((String? token) async{
       await  SharedPreferencesUtils.setFcmToken(token ?? "");
      });
    }
  }
  else{
    _fcm.getToken().then((String? token) async{
      log("Android FCM token: $token");
      SharedPreferencesUtils.setFcmToken(token ?? "");
    });
  }
}


  void notificationTapReceive(NotificationResponse notificationResponse)async{
    // handle action
    print("notificationTapReceive afvfvsfs:${jsonDecode(notificationResponse.payload!)}");
    NotificationsActionsManager? _notificationsActionsManager;
    print("notificationTapReceive:${jsonDecode(notificationResponse.payload!)}");
    _notificationsActionsManager = NotificationsActionsManager.getInstance(NavigationService.navigatorKey.currentContext!);
    print("notificationTapReceive:${jsonDecode(notificationResponse.payload!)}");
    await  _notificationsActionsManager!.performAction(varag: jsonDecode(notificationResponse.payload!));

  }



  Future initialize() async{
    // Skip flutter_local_notifications on web (not supported)
    if (PlatformHelper.isWeb) {
      log('⚠️ flutter_local_notifications not available on web - using browser notifications');
      return;
    }

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings("launch");

    DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse: notificationTapReceive, );

  }

  requestFlutterLocalPermissions() async{
    // Skip on web - browser handles permissions
    if (PlatformHelper.isWeb) {
      log('⚠️ Skipping flutter_local_notifications permissions on web');
      return;
    }

    if (PlatformHelper.isIOS) {
      final bool? granted =  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true

      );
      print("iOS notification permissions granted: $granted");
    }


  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future instantNotification(String message,String title,String payload,{String? imageUrl}) async{
   // On web, Firebase handles notifications automatically through the service worker
   if (PlatformHelper.isWeb) {
     log('ℹ️ Web platform - notifications handled by browser/service worker');
     return;
   }

   log("error image:$imageUrl");
   String? bigPicturePath;
   File? file;
   List<DarwinNotificationAttachment>? attachments;
   BigPictureStyleInformation? bigPictureStyleInformation;
    try{
      if (imageUrl != null) {
        log("📸 Attempting to download image: $imageUrl");
        if(PlatformHelper.isAndroid){
          bigPicturePath = await downloadAndSaveFile(imageUrl, 'bigPicture.jpg');
          log("✅ Android image downloaded to: $bigPicturePath");
          if (bigPicturePath != null && bigPicturePath.isNotEmpty) {
            bigPictureStyleInformation = BigPictureStyleInformation(
              FilePathAndroidBitmap(bigPicturePath),
              contentTitle:title,
              summaryText: message,
            );
            log("✅ BigPictureStyleInformation created successfully");
          } else {
            log("⚠️ Failed to download image - bigPicturePath is null or empty");
          }
        }else{
          final tempDir = await getTemporaryDirectory();
          file = await downloadImage(imageUrl, tempDir);
          if (file != null) {
            final attachment = DarwinNotificationAttachment(file.path);
            attachments = [attachment];
            log("✅ iOS image attachment created: ${file.path}");
          } else {
            log("⚠️ Failed to download image for iOS");
          }
        }
      } else {
        log("ℹ️ No image URL provided for notification");
      }
    }catch(e){
      log("❌ Error downloading notification image: ${e.toString()}");
    }

   var android =  AndroidNotificationDetails(
       "android", "channel",channelDescription: "description",priority: Priority.high, importance: Importance.max,
       playSound: true,
       sound: RawResourceAndroidNotificationSound("coin_sound"),
       icon: "ic_launcher",
       ticker: 'ticker',
       color: odaPrimary,
       channelShowBadge: true,
       colorized: true,
       enableVibration: true,
       showWhen: true,
       styleInformation: bigPictureStyleInformation,
       // This ensures notification tap works when app is killed on Android
       category: AndroidNotificationCategory.message,
       visibility: NotificationVisibility.public,
   );

   var ios =  DarwinNotificationDetails(presentBadge: true,presentAlert: true,presentSound: true,attachments: attachments);

   var platforms = new NotificationDetails(android: android, iOS: ios);

   await flutterLocalNotificationsPlugin.show(0, "$title", "$message", platforms,payload: payload,);
}



Future<String?> downloadAndSaveFile(String url, String fileName) async {
  // This function only works on mobile platforms (uses dart:io File)
  if (PlatformHelper.isWeb) {
    log("⚠️ downloadAndSaveFile not supported on web");
    return null;
  }

  try {
    log("📥 Downloading Android notification image from: $url");
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      log("✅ Image saved successfully to: $filePath (${response.bodyBytes.length} bytes)");
      return filePath;
    } else {
      log("❌ Failed to download image: HTTP ${response.statusCode}");
      return null;
    }
  } catch (e) {
    log("❌ Error in downloadAndSaveFile: ${e.toString()}");
    return null;
  }
}

Future<File?> downloadImage(String url, Directory tempDir) async {
  // This function only works on mobile platforms (uses dart:io File)
  if (PlatformHelper.isWeb) {
    log("⚠️ downloadImage not supported on web");
    return null;
  }

  try {
    log("📥 Downloading iOS notification image from: $url");
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      log("✅ iOS image saved successfully to: ${file.path} (${response.bodyBytes.length} bytes)");
      return file;
    } else {
      log("❌ Failed to download iOS image: HTTP ${response.statusCode}");
      return null;
    }
  } catch (e) {
    log("❌ Error in downloadImage: ${e.toString()}");
    return null;
  }
}