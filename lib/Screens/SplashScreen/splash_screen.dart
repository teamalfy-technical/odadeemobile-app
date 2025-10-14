import 'dart:async';

import 'package:flutter/material.dart';
import 'package:odadee/Screens/Onboarding/Onboarding_screen.dart';
import 'package:odadee/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  Widget build(BuildContext context) {

    Timer(
        Duration(seconds: 3),
            ()=> Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => OnboardingScreen()))
    );

    return Scaffold(
      body: Container(
        color: odaPrimary,
        child: Center(
          child: Image.asset("assets/images/oda_logo.png"),
        ),
      ),

    );
  }
}
