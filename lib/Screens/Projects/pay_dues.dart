import 'package:flutter/material.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/components/footer_nav.dart';
import 'package:odadee/components/pay_dues_modal.dart';

class PayDuesScreen extends StatefulWidget {
  const PayDuesScreen({Key? key}) : super(key: key);

  @override
  State<PayDuesScreen> createState() => _PayDuesScreenState();
}

class _PayDuesScreenState extends State<PayDuesScreen> {
  @override
  void initState() {
    super.initState();
    // Show payment modal after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPayDuesModal();
    });
  }

  void _showPayDuesModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PayDuesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pay Dues",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Stack(
                          children: [
                            Icon(
                              Icons.notifications_none_outlined,
                              color: odaSecondary,
                              size: 30,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: odaSecondary,
                                radius: 5,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage("assets/images/paydues.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Pay Your Year Group Dues',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Support your year group by paying your annual dues. Contributions help fund year group activities, events, and initiatives.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF94a3b8),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _showPayDuesModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: odaPrimary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.payment, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Make Payment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFF1e293b),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFF334155),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: odaPrimary,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Payment Information',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.security,
                                'Secure payments powered by PayAngel',
                              ),
                              SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.account_balance_wallet,
                                'Pay with mobile money or card',
                              ),
                              SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.receipt_long,
                                'Instant payment confirmation',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FooterNav(activeTab: 'pay_dues'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color(0xFF94a3b8),
          size: 18,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Color(0xFF94a3b8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
