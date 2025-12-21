import 'dart:async';
import 'package:flutter/foundation.dart';
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
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (kIsWeb) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse('splash_video.webm'),
        );
      } else {
        _controller =
            VideoPlayerController.asset('assets/videos/splash_video.mp4');
      }

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _initialized = true;
        });

        _controller!.setVolume(0.0);
        _controller!.setLooping(false);
        _controller!.play();

        Timer(const Duration(milliseconds: 3500), _navigateToOnboarding);
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      Timer(const Duration(milliseconds: 3500), _navigateToOnboarding);
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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _initialized &&
              _controller != null &&
              _controller!.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          : Container(
              color: odaBackground,
              child: Center(
                child: Image.asset(
                  "assets/images/presec_logo.webp",
                  width: 250,
                ),
              ),
            ),
    );
  }
}
