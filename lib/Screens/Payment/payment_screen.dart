import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:odadee/constants.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  WebViewController? _controller;
  bool isLoading = true;
  bool paymentLaunched = false;

  @override
  void initState() {
    super.initState();
    
    if (kIsWeb) {
      // For Flutter Web, launch payment URL in new tab
      _launchPaymentForWeb();
    } else {
      // For mobile platforms, use WebView
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0f172a))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('PaymentScreen navigation to: ${request.url}');
            
            final uri = Uri.parse(request.url);
            
            // Check for PayAngel callback with transactionStatus
            if (uri.path.contains('/payments/callback') || 
                uri.queryParameters.containsKey('transactionStatus')) {
              final transactionStatus = uri.queryParameters['transactionStatus']?.toUpperCase();
              print('PayAngel callback detected: transactionStatus=$transactionStatus');
              
              if (transactionStatus == 'SUCCESS' || transactionStatus == 'SUCCESSFUL') {
                Navigator.pop(context, true);
                return NavigationDecision.prevent;
              } else if (transactionStatus == 'FAILED' || 
                         transactionStatus == 'FAILURE' || 
                         transactionStatus == 'CANCELLED' ||
                         transactionStatus == 'CANCELED') {
                Navigator.pop(context, false);
                return NavigationDecision.prevent;
              }
            }
            
            // Fallback: Check for generic status query param
            if (uri.queryParameters.containsKey('status')) {
              final status = uri.queryParameters['status']?.toLowerCase();
              print('Generic status param detected: $status');
              if (status == 'success' || status == 'successful') {
                Navigator.pop(context, true);
                return NavigationDecision.prevent;
              } else if (status == 'failed' || status == 'failure' || status == 'cancelled' || status == 'canceled') {
                Navigator.pop(context, false);
                return NavigationDecision.prevent;
              }
            }
            
            // Fallback: Check URL path for callbacks
            if (request.url.contains('/payment/success') || 
                request.url.contains('/payments/success')) {
              print('Success URL pattern detected');
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            
            if (request.url.contains('/payment/failed') || 
                request.url.contains('/payments/failed') ||
                request.url.contains('/payment/cancel')) {
              print('Failure URL pattern detected');
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _launchPaymentForWeb() async {
    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse(widget.paymentUrl);
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched && mounted) {
          setState(() {
            isLoading = false;
            paymentLaunched = true;
          });
        } else {
          throw 'Failed to launch payment URL';
        }
      } else {
        throw 'Could not launch payment URL';
      }
    } catch (e) {
      print('Error launching payment URL: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open payment page. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web: Show confirmation screen
      return _buildWebConfirmationScreen();
    } else {
      // Mobile: Use WebView
      return _buildMobileWebViewScreen();
    }
  }

  Widget _buildWebConfirmationScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        title: Text(
          'Complete Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF0f172a),
        elevation: 0,
        iconTheme: IconThemeData(color: odaSecondary),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                ),
                SizedBox(height: 24),
                Text(
                  'Opening payment page...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ] else if (paymentLaunched) ...[
                Icon(
                  Icons.open_in_new,
                  color: odaSecondary,
                  size: 64,
                ),
                SizedBox(height: 24),
                Text(
                  'Payment Page Opened',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Please complete your payment in the new tab that just opened, then return here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  'Did you complete the payment?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: odaPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text('Yes, Payment Complete'),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white30),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _launchPaymentForWeb,
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Reopen Payment Page'),
                  style: TextButton.styleFrom(
                    foregroundColor: odaSecondary,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                SizedBox(height: 24),
                Text(
                  'Failed to Open Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _launchPaymentForWeb,
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: odaPrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileWebViewScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        title: Text(
          'Complete Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF0f172a),
        elevation: 0,
        iconTheme: IconThemeData(color: odaSecondary),
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading payment page...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
