import 'package:flutter/material.dart';
import 'package:odadee/Screens/Dashboard/dashboard_screen.dart';
import 'package:odadee/Screens/Authentication/SignIn/sgin_in_screen.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/constants.dart';

class MagicLinkCallbackScreen extends StatefulWidget {
  final String token;

  const MagicLinkCallbackScreen({Key? key, required this.token})
      : super(key: key);

  @override
  State<MagicLinkCallbackScreen> createState() =>
      _MagicLinkCallbackScreenState();
}

class _MagicLinkCallbackScreenState extends State<MagicLinkCallbackScreen> {
  bool _isVerifying = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyToken();
  }

  Future<void> _verifyToken() async {
    try {
      final authService = AuthService();
      await authService.verifyMagicLink(widget.token);

      if (mounted) {
        // Success - navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: odaBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isVerifying) ...[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(odaSecondary),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Verifying your magic link...',
                    style: TextStyle(
                      fontSize: 18,
                      color: bodyText1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Verification Failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: bodyText1,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Invalid or expired magic link',
                    style: TextStyle(
                      fontSize: 16,
                      color: bodyText2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SignInScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: odaSecondary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
