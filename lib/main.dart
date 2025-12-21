// @dart=2.12
import 'dart:developer';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odadee/navigation_service.dart';
import 'package:odadee/services/notifications/notification_controller.dart';
import 'package:odadee/utils/shared_preferance_util.dart';
import 'package:provider/provider.dart';
import 'package:odadee/Screens/Dashboard/dashboard_screen.dart';
import 'package:odadee/Screens/SplashScreen/splash_screen.dart';
import 'package:odadee/Screens/Authentication/magic_link_callback.dart';
import 'package:odadee/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:odadee/firebase_options.dart';
import 'package:odadee/services/migration_helper.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MigrationHelper.migrateAuthStorage();

  // Initialize ThemeService
  final themeService = ThemeService();
  await themeService.initialize();

  SharedPreferencesUtils.prefs = await SharedPreferences.getInstance();

  // Initialize Firebase (required before using FirebaseMessaging)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('✅ Firebase initialized successfully');
  } catch (e) {
    log('❌ Error initializing Firebase: $e');
  }

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) => {
            runApp(
              // DevicePreview(
              //     enabled: !kReleaseMode, builder: (context) => const MyApp()),
              MyApp()
            )
          });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1), () async {
      log('📱 MyApp initState - Initializing notifications');
      await NotificationController().initialise(showInitialNotification: true,listenNotification: true);
      await NotificationController().initialize();
      NotificationController().requestFlutterLocalPermissions();
      log('✅ Notification initialization complete');
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide the keyboard when tapping outside the text field
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ChangeNotifierProvider<ThemeService>(
        create: (_) => ThemeService(),
        child: Consumer<ThemeService>(
          builder: (context, themeService, _) {
            Widget app = MaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Odade3',
              theme: themeService.isDarkMode
                  ? themeService.getDarkTheme()
                  : themeService.getLightTheme(),
              home: MyHomePage(),
            );

            // Center the app on web with max width
            if (kIsWeb) {
              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: app,
                ),
              );
            }

            return app;
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? _isLoggedIn;
  bool _isLoading = true;
  bool _hasMagicLinkToken = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _checkForMagicLink();
    _checkAuthStatus();
  }

  void _checkForMagicLink() {
    if (kIsWeb) {
      // Check if the URL contains magic link token
      final uri = Uri.base;
      print('Checking URL: ${uri.toString()}');

      String? token;

      // Pattern 1: /auth/magic-link/:token (production)
      if (uri.path.contains('/auth/magic-link/')) {
        final segments = uri.pathSegments;
        final index = segments.indexOf('magic-link');
        if (index >= 0 && index + 1 < segments.length) {
          token = segments[index + 1];
          print('Found magic link token (path): $token');
        }
      }
      // Pattern 2: /auth/verify?token=xyz (local testing)
      else if (uri.path.contains('/auth/verify')) {
        token = uri.queryParameters['token'];
        print('Found magic link token (query): $token');
      }

      if (token != null && token.isNotEmpty) {
        setState(() {
          _hasMagicLinkToken = true;
          _token = token;
        });
      }
    }
  }

  Future<void> _checkAuthStatus() async {
    print('===== CHECKING AUTH STATUS =====');
    try {
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      print('Auth check result: $isLoggedIn');
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }
      print('Navigation target: ${isLoggedIn ? "Dashboard" : "Splash"}');
    } catch (e) {
      print('Error checking auth status: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If magic link token detected, show callback screen
    if (_hasMagicLinkToken && _token != null) {
      print('Routing to MagicLinkCallbackScreen with token');
      return MagicLinkCallbackScreen(token: _token!);
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: odaBackground,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
          ),
        ),
      );
    }

    return (_isLoggedIn == true)
        ? const DashboardScreen()
        : const SplashScreen();
  }
}
