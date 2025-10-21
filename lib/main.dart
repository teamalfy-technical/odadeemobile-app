// @dart=2.12
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odadee/Screens/Dashboard/dashboard_screen.dart';
import 'package:odadee/Screens/SplashScreen/splash_screen.dart';
import 'package:odadee/constants.dart';

import 'components/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*await Firebase.initializeApp();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  //log("FCMToken $fcmToken");*/

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) => {
            runApp(
              DevicePreview(
                  enabled: !kReleaseMode, builder: (context) => const MyApp()),
              // MyApp()
            )
          });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide the keyboard when tapping outside the text field
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Odade3',
        theme: theme(),
        home: MyHomePage(),
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
  String? api_key;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    api_key = await getApiPref();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return (api_key == null || api_key!.isEmpty) 
        ? const SplashScreen() 
        : const DashboardScreen();
  }
}
