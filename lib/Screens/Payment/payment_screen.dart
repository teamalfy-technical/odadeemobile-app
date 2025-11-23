import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:odadee/constants.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentScreen({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0f172a))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
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

  @override
  Widget build(BuildContext context) {
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
          WebViewWidget(controller: _controller),
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
