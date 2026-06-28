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
  bool _isDisposed = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = kIsWeb
          ? VideoPlayerController.networkUrl(
              Uri.parse('splash_video.webm'),
            )
          : VideoPlayerController.asset('assets/videos/splash_video.mp4');
      _controller = controller;

      await controller.initialize();

      if (_isDisposed || !mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _initialized = true;
      });

      controller.setVolume(0.0);
      // Loop instead of letting the video reach natural completion: on
      // completion the plugin internally does pause().then((_) =>
      // seekTo(...)), and that dangling continuation can run after we've
      // disposed the controller (when our navigation timer fires around
      // the same time the video ends), which crashes with "used after
      // being disposed". We navigate away on our own timer regardless, so
      // looping is harmless here and avoids the completion event entirely.
      controller.setLooping(true);
      controller.play();

      _navigationTimer =
          Timer(const Duration(milliseconds: 3500), _navigateToOnboarding);
    } catch (e) {
      debugPrint('Video initialization error: $e');
      _navigationTimer =
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
    _isDisposed = true;
    _navigationTimer?.cancel();
    _disposeController();
    super.dispose();
  }

  // video_player's internal position-polling timer checks `_isDisposed`
  // before awaiting the platform call but not after, so it can still
  // call notifyListeners() on a controller that finished disposing while
  // the await was pending. Pausing first cancels that timer, and awaiting
  // pause() before dispose() closes most of that window.
  Future<void> _disposeController() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.pause();
    } catch (_) {
      // Ignore: controller may already be in a bad state during teardown.
    }
    await controller.dispose();
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
