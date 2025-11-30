import 'package:flutter/material.dart';
import 'package:odadee/models/project.dart';
import 'package:odadee/constants.dart';
import 'package:intl/intl.dart';
import 'package:odadee/services/payment_service.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/services/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final dynamic data;

  const ProjectDetailsScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  Project? get project => widget.data is Project ? widget.data as Project : null;
  final PaymentService _paymentService = PaymentService();
  
  bool _isContributing = false;
  final TextEditingController _amountController = TextEditingController();

  String _formatCurrency(double? amount) {
    final formatter = NumberFormat('#,##0.00');
    return 'GH₵ ${formatter.format(amount ?? 0.0)}';
  }
  
  String _getProgressPercentage() {
    if (project == null || (project!.targetAmount ?? 0) == 0) return '0.0';
    final current = project!.currentAmount ?? 0.0;
    final target = project!.targetAmount ?? 1.0;
    if (target == 0) return '0.0';
    final percentage = (current / target * 100);
    return percentage.toStringAsFixed(1);
  }
  
  bool _isOverfunded() {
    if (project == null || (project!.targetAmount ?? 0) == 0) return false;
    final current = project!.currentAmount ?? 0.0;
    final target = project!.targetAmount ?? 1.0;
    return current > target;
  }

  void _showContributeSheet() {
    final cardColor = AppColors.cardColor(context);
    final surfaceColor = AppColors.surfaceColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    final borderColor = AppColors.borderColor(context);
    
    _amountController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contribute to Project',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: subtitleColor),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  project!.title,
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                SizedBox(height: 24),
                
                Text(
                  'Enter Amount (GH₵)',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: 'GH₵ ',
                    prefixStyle: TextStyle(color: odaSecondary, fontSize: 24, fontWeight: FontWeight.bold),
                    hintText: '0.00',
                    hintStyle: TextStyle(color: mutedColor, fontSize: 24),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: odaPrimary),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                
                Text(
                  'Quick amounts:',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                SizedBox(height: 8),
                Row(
                  children: [50.0, 100.0, 200.0, 500.0].map((amount) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: amount == 500.0 ? 0 : 8),
                        child: OutlinedButton(
                          onPressed: () {
                            _amountController.text = amount.toStringAsFixed(2);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '₵${amount.toInt()}',
                            style: TextStyle(color: subtitleColor),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                SizedBox(height: 24),
                
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: odaPrimary, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will be redirected to complete payment via PayAngel',
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isContributing ? null : () async {
                      final amount = double.tryParse(_amountController.text) ?? 0;
                      if (amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid amount'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      setModalState(() => _isContributing = true);
                      
                      try {
                        print('=== PROJECT PAYMENT DEBUG ===');
                        print('Project ID: ${project!.id}');
                        print('Project yearGroupId: ${project!.yearGroupId}');
                        print('Amount: $amount');
                        
                        String yearGroupId = project!.yearGroupId ?? '';
                        if (yearGroupId.isEmpty) {
                          print('Project has no yearGroupId, fetching from user...');
                          final authService = AuthService();
                          
                          // Try cached data first, then API
                          Map<String, dynamic>? userData;
                          userData = await authService.getCachedUser();
                          print('Cached user data: $userData');
                          
                          if (userData == null) {
                            try {
                              userData = await authService.getCurrentUser();
                              print('User data from API: $userData');
                            } catch (e) {
                              print('API fetch failed: $e');
                              throw Exception('Your session has expired. Please log out and log in again.');
                            }
                          }
                          
                          print('User data keys: ${userData?.keys.toList()}');
                          
                          yearGroupId = userData?['yearGroupId']?.toString() ?? '';
                          if (yearGroupId.isEmpty) {
                            yearGroupId = userData?['yearGroup']?.toString() ?? '';
                          }
                          if (yearGroupId.isEmpty) {
                            yearGroupId = userData?['graduationYear']?.toString() ?? '';
                          }
                          if (yearGroupId.isEmpty && userData?['yearGroup'] is Map) {
                            yearGroupId = (userData!['yearGroup'] as Map)['id']?.toString() ?? 
                                         (userData['yearGroup'] as Map)['_id']?.toString() ?? '';
                          }
                          print('Resolved yearGroupId from user: "$yearGroupId"');
                        }
                        
                        if (yearGroupId.isEmpty) {
                          throw Exception('Could not determine year group. Please update your profile with your graduation year.');
                        }
                        
                        print('Final yearGroupId: $yearGroupId');
                        print('Calling payment service...');
                        
                        final paymentUrl = await _paymentService.createPayment(
                          paymentType: 'project',
                          amount: amount,
                          yearGroupId: yearGroupId,
                          projectId: project!.id,
                          description: 'Contribution to ${project!.title}',
                        );
                        
                        print('Payment URL received: $paymentUrl');
                        
                        Navigator.pop(context);
                        
                        _showPaymentConfirmation(paymentUrl, amount);
                      } catch (e) {
                        print('Payment error: $e');
                        setModalState(() => _isContributing = false);
                        
                        String errorMessage = e.toString();
                        if (errorMessage.startsWith('Exception: ')) {
                          errorMessage = errorMessage.substring(11);
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: odaPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isContributing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Continue to Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() => _isContributing = false);
    });
  }

  void _showPaymentConfirmation(String paymentUrl, double amount) {
    final cardColor = AppColors.cardColor(context);
    final surfaceColor = AppColors.surfaceColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.payment, color: odaPrimary, size: 28),
            SizedBox(width: 12),
            Text(
              'Complete Payment',
              style: TextStyle(color: textColor, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your contribution of GH₵ ${amount.toStringAsFixed(2)} is ready.',
              style: TextStyle(color: subtitleColor),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentInfoRow('Project', project!.title, textColor, subtitleColor),
                  SizedBox(height: 8),
                  _buildPaymentInfoRow('Amount', 'GH₵ ${amount.toStringAsFixed(2)}', textColor, subtitleColor),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Click "Pay Now" to open the payment page. After completing payment, return to the app.',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(paymentUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Complete your payment in the browser, then return to the app.'),
                    backgroundColor: odaPrimary,
                    duration: Duration(seconds: 5),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not open payment page'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: odaPrimary,
            ),
            child: Text('Pay Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(String label, String value, Color textColor, Color subtitleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: subtitleColor, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 13),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = AppColors.cardColor(context);
    final borderColor = AppColors.borderColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    
    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Project Details'),
        ),
        body: Center(child: Text('Project not found', style: TextStyle(color: textColor))),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Project Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project!.imageUrl != null && project!.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: cardColor,
                ),
                child: Image.network(
                  project!.imageUrl!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: cardColor,
                      child: Center(
                        child: Icon(
                          Icons.work,
                          size: 80,
                          color: mutedColor,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: cardColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: cardColor,
                child: Center(
                  child: Icon(
                    Icons.work,
                    size: 80,
                    color: mutedColor,
                  ),
                ),
              ),
            
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (project!.category.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: odaPrimary.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: odaPrimary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            project!.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: odaPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Spacer(),
                      if (project!.status.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: project!.status == 'active'
                                ? Color(0xFF10b981).withAlpha(51)
                                : mutedColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            project!.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: project!.status == 'active' 
                                  ? Color(0xFF10b981) 
                                  : subtitleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  Text(
                    project!.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: odaSecondary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Funding Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final containerWidth = constraints.maxWidth;
                            final currentAmt = project!.currentAmount ?? 0.0;
                            final targetAmt = project!.targetAmount ?? 1.0;
                            final rawRatio = targetAmt > 0 ? currentAmt / targetAmt : 0.0;
                            final overflowRatio = rawRatio > 1.0 ? (rawRatio - 1.0) : 0.0;
                            final overflowWidth = containerWidth * overflowRatio;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: rawRatio.clamp(0.0, 1.0),
                                    minHeight: 12,
                                    backgroundColor: borderColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      rawRatio >= 1.0 ? Color(0xFF10b981) : odaPrimary
                                    ),
                                  ),
                                ),
                                if (rawRatio > 1.0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: overflowWidth.clamp(0.0, containerWidth),
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF10b981).withAlpha(128),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        
                        SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Raised',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatCurrency(project!.currentAmount),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Goal',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatCurrency(project!.targetAmount),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isOverfunded()
                                  ? Color(0xFF10b981).withAlpha(51)
                                  : odaPrimary.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_getProgressPercentage()}% Funded${_isOverfunded() ? ' - Goal Exceeded!' : ''}',
                              style: TextStyle(
                                color: _isOverfunded() ? Color(0xFF10b981) : odaPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  Text(
                    'About this project',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    project!.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: project!.status == 'active' ? _showContributeSheet : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: odaPrimary,
                        disabledBackgroundColor: mutedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            project!.status == 'active' ? 'Contribute to Project' : 'Project Closed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
