// @dart=2.12

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
      .then((value) => {runApp(MyApp())});
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
  String? api_key = "";
  Future? _user_api;

  @override
  void initState() {
    super.initState();
    _user_api = apiKey();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _user_api,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //return SettingsScreen();
          return api_key == null ? SplashScreen() : DashboardScreen();



        });
  }

  Future apiKey() async {
    api_key = await getApiPref();
  }
}
