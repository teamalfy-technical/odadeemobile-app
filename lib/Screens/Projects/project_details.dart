import 'package:flutter/material.dart';
import 'package:odadee/models/project.dart';
import 'package:odadee/config/api_config.dart';
import 'package:odadee/constants.dart';
import 'package:intl/intl.dart';
import 'package:odadee/services/payment_service.dart';
import 'package:odadee/services/auth_service.dart';
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

  double _getFundingProgress() {
    if (project == null || (project!.targetAmount ?? 0) == 0) return 0.0;
    final current = project!.currentAmount ?? 0.0;
    final target = project!.targetAmount ?? 1.0;
    if (target == 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
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
    _amountController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1e293b),
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
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Color(0xFF94a3b8)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  project!.title,
                  style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                ),
                SizedBox(height: 24),
                
                Text(
                  'Enter Amount (GH₵)',
                  style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: 'GH₵ ',
                    prefixStyle: TextStyle(color: Color(0xFFf4d03f), fontSize: 24, fontWeight: FontWeight.bold),
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Color(0xFF64748b), fontSize: 24),
                    filled: true,
                    fillColor: Color(0xFF0f172a),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF334155)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF2563eb)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                
                Text(
                  'Quick amounts:',
                  style: TextStyle(color: Color(0xFF64748b), fontSize: 12),
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
                            side: BorderSide(color: Color(0xFF334155)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '₵${amount.toInt()}',
                            style: TextStyle(color: Color(0xFF94a3b8)),
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
                    color: Color(0xFF0f172a),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF2563eb), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will be redirected to complete payment via PayAngel',
                          style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
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
                        String yearGroupId = project!.yearGroupId ?? '';
                        if (yearGroupId.isEmpty) {
                          final authService = AuthService();
                          final userData = await authService.getCurrentUser();
                          yearGroupId = userData['yearGroupId']?.toString() ?? 
                                       userData['yearGroup']?.toString() ?? 
                                       userData['graduationYear']?.toString() ?? '';
                        }
                        
                        final paymentUrl = await _paymentService.createPayment(
                          paymentType: 'project',
                          amount: amount,
                          yearGroupId: yearGroupId,
                          projectId: project!.id,
                          description: 'Contribution to ${project!.title}',
                        );
                        
                        Navigator.pop(context);
                        
                        _showPaymentConfirmation(paymentUrl, amount);
                      } catch (e) {
                        setModalState(() => _isContributing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563eb),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1e293b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.payment, color: Color(0xFF2563eb), size: 28),
            SizedBox(width: 12),
            Text(
              'Complete Payment',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your contribution of GH₵ ${amount.toStringAsFixed(2)} is ready.',
              style: TextStyle(color: Color(0xFF94a3b8)),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF0f172a),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentInfoRow('Project', project!.title),
                  SizedBox(height: 8),
                  _buildPaymentInfoRow('Amount', 'GH₵ ${amount.toStringAsFixed(2)}'),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Click "Pay Now" to open the payment page. After completing payment, return to the app.',
              style: TextStyle(color: Color(0xFF64748b), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF94a3b8))),
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
                    backgroundColor: Color(0xFF2563eb),
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
              backgroundColor: Color(0xFF2563eb),
            ),
            child: Text('Pay Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
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
    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Project Details', style: TextStyle(color: Colors.black)),
        ),
        body: Center(child: Text('Project not found')),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Project Details',
          style: TextStyle(
            color: Colors.black,
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
                  color: Color(0xFF1e293b),
                ),
                child: Image.network(
                  project!.imageUrl!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFF1e293b),
                      child: Center(
                        child: Icon(
                          Icons.work,
                          size: 80,
                          color: Color(0xFF64748b),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Color(0xFF1e293b),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563eb)),
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
                color: Color(0xFF1e293b),
                child: Center(
                  child: Icon(
                    Icons.work,
                    size: 80,
                    color: Color(0xFF64748b),
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
                            color: Color(0xFF2563eb).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFF2563eb),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            project!.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2563eb),
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
                                ? Color(0xFF10b981).withOpacity(0.2)
                                : Color(0xFF64748b).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            project!.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: project!.status == 'active' 
                                  ? Color(0xFF10b981) 
                                  : Color(0xFF94a3b8),
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFf4d03f),
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
                            color: Colors.white,
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
                                    backgroundColor: Color(0xFF334155),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      rawRatio >= 1.0 ? Color(0xFF10b981) : Color(0xFF2563eb)
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
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              height: 6,
                                              width: overflowWidth,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF10b981),
                                                    Color(0xFFf4d03f),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 10,
                                            color: Color(0xFFf4d03f),
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
                                    fontSize: 12,
                                    color: Color(0xFF94a3b8),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatCurrency(project!.currentAmount),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF2563eb),
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
                                    fontSize: 12,
                                    color: Color(0xFF94a3b8),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatCurrency(project!.targetAmount),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        Center(
                          child: Column(
                            children: [
                              Text(
                                '${_getProgressPercentage()}% funded',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFf4d03f),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_isOverfunded())
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'GOAL EXCEEDED',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF10b981),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    project!.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94a3b8),
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
                        backgroundColor: Color(0xFF2563eb),
                        disabledBackgroundColor: Color(0xFF64748b),
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
                            project!.status == 'active' 
                                ? 'Contribute to Project' 
                                : 'Project Not Active',
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
