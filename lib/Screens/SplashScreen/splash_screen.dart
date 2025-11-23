import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:odadee/Screens/Onboarding/Onboarding_screen.dart';
import 'package:odadee/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/images/splash_video.mp4');
    
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        
        // Start playing the video
        await _controller.play();
        
        // Listen for when video completes
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration && !_hasNavigated) {
            _navigateToOnboarding();
          }
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      // If video fails to load, navigate after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_hasNavigated) {
          _navigateToOnboarding();
        }
      });
    }
  }

  void _navigateToOnboarding() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: odaBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background color
          Container(
            color: odaBackground,
          ),
          
          // Video player
          if (_isVideoInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            // Loading fallback
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/oda_logo.png",
                    width: 150,
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(odaSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
