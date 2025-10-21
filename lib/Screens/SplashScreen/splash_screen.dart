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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const OnboardingScreen(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
