import 'package:flutter/material.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/components/footer_nav.dart';
import 'package:odadee/components/pay_dues_modal.dart';
import 'package:odadee/services/auth_service.dart';

class PayDuesScreen extends StatefulWidget {
  const PayDuesScreen({Key? key}) : super(key: key);

  @override
  State<PayDuesScreen> createState() => _PayDuesScreenState();
}

class _PayDuesScreenState extends State<PayDuesScreen> {
  final authService = AuthService();
  String yearGroupName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserYearGroup();
    // Show payment modal after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPayDuesModal();
    });
  }

  Future<void> _loadUserYearGroup() async {
    try {
      final userData = await authService.getCachedUser();
      if (userData != null && userData['yearGroup'] != null) {
        setState(() {
          yearGroupName = userData['yearGroup'].toString();
          isLoading = false;
        });
      } else {
        // Fallback: fetch from API
        final freshUserData = await authService.getCurrentUser();
        setState(() {
          yearGroupName = freshUserData['yearGroup']?.toString() ?? 'Your Year Group';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading year group: $e');
      setState(() {
        yearGroupName = 'Your Year Group';
        isLoading = false;
      });
    }
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
                        // Year Group Impact Stats Card
                        isLoading
                            ? Center(child: CircularProgressIndicator(color: odaSecondary))
                            : Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1e293b),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: odaSecondary,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: odaPrimary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.trending_up,
                                            color: odaSecondary,
                                            size: 28,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                yearGroupName.isNotEmpty 
                                                    ? '$yearGroupName Impact'
                                                    : 'Your Year Group Impact',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Collective contributions matter',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF94a3b8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: odaPrimary.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: odaPrimary.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.bar_chart_rounded,
                                            color: odaSecondary,
                                            size: 48,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Payment Statistics Coming Soon',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Track your year group\'s collective impact and contributions',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF94a3b8),
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: odaPrimary.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.volunteer_activism,
                                            color: odaSecondary,
                                            size: 20,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Be part of the change! Your contribution helps fund ${yearGroupName.isNotEmpty ? yearGroupName : 'year group'} activities and strengthens our community.',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFcbd5e1),
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
