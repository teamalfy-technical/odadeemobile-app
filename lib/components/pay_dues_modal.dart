import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:odadee/Screens/Payment/payment_screen.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/services/payment_service.dart';

class PayDuesModal extends StatefulWidget {
  const PayDuesModal({super.key});

  @override
  State<PayDuesModal> createState() => _PayDuesModalState();
}

class _PayDuesModalState extends State<PayDuesModal> {
  List<Map<String, dynamic>> yearGroups = [];
  List<Map<String, dynamic>> duesItems = [];
  
  String? selectedYearGroupId;
  String? selectedYearGroupName;
  String? selectedDuesId;
  String? selectedDuesTitle;
  double? selectedDuesAmount;
  
  bool isLoadingYearGroups = true;
  bool isLoadingDues = false;
  bool isProcessingPayment = false;
  
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchYearGroups();
  }

  Future<void> _fetchYearGroups() async {
    try {
      setState(() {
        isLoadingYearGroups = true;
        errorMessage = null;
      });

      final authService = AuthService();
      final response = await authService.authenticatedRequest(
        'GET',
        '/api/year-groups',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> groups = data['yearGroups'] ?? [];
        
        setState(() {
          yearGroups = groups.map((g) => {
            'id': g['id'],
            'name': g['name'] ?? 'Class of ${g['year']}',
            'year': g['year'],
          }).toList();
          isLoadingYearGroups = false;
          
          // Auto-select first year group
          if (yearGroups.isNotEmpty) {
            selectedYearGroupId = yearGroups[0]['id'];
            selectedYearGroupName = yearGroups[0]['name'];
            _fetchDuesForYearGroup(selectedYearGroupId!);
          }
        });
      } else {
        throw Exception('Failed to load year groups');
      }
    } catch (e) {
      setState(() {
        isLoadingYearGroups = false;
        errorMessage = 'Failed to load year groups: $e';
      });
    }
  }

  Future<void> _fetchDuesForYearGroup(String yearGroupId) async {
    try {
      setState(() {
        isLoadingDues = true;
        errorMessage = null;
      });

      final authService = AuthService();
      final response = await authService.authenticatedRequest(
        'GET',
        '/api/year-groups/$yearGroupId/dues',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> dues = data['dues'] ?? [];
        
        final newDuesItems = dues.map((d) => {
          'id': d['id'],
          'title': d['title'],
          'amount': (d['amount'] is String) 
              ? double.parse(d['amount']) 
              : (d['amount'] as num).toDouble(),
          'currency': d['currency'] ?? 'GHS',
          'description': d['description'],
        }).toList();
        
        setState(() {
          duesItems = newDuesItems;
          isLoadingDues = false;
          
          // Auto-select first dues item after fetching
          if (duesItems.isNotEmpty) {
            selectedDuesId = duesItems[0]['id'];
            selectedDuesTitle = duesItems[0]['title'];
            selectedDuesAmount = duesItems[0]['amount'];
          } else {
            // Clear selections if no dues available
            selectedDuesId = null;
            selectedDuesTitle = null;
            selectedDuesAmount = null;
          }
        });
      } else {
        throw Exception('Failed to load dues items');
      }
    } catch (e) {
      setState(() {
        isLoadingDues = false;
        duesItems = [];
        selectedDuesId = null;
        selectedDuesTitle = null;
        selectedDuesAmount = null;
        errorMessage = 'Failed to load dues items: $e';
      });
    }
  }

  Future<void> _proceedToPayment() async {
    if (selectedYearGroupId == null || selectedDuesId == null || selectedDuesAmount == null) {
      setState(() {
        errorMessage = 'Please select a year group and dues item';
      });
      return;
    }

    try {
      setState(() {
        isProcessingPayment = true;
        errorMessage = null;
      });

      final paymentService = PaymentService();
      final paymentUrl = await paymentService.createPayment(
        paymentType: 'dues',
        amount: selectedDuesAmount!,
        yearGroupId: selectedYearGroupId!,
        description: selectedDuesTitle,
      );

      setState(() {
        isProcessingPayment = false;
      });

      // Open payment screen
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(paymentUrl: paymentUrl),
        ),
      );

      // Handle payment result
      if (!mounted) return;
      
      if (result == true) {
        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful! Thank you for your contribution.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (result == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment cancelled or failed. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
        errorMessage = 'Payment error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF334155),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pay Year Group Dues',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select your year group and the dues you want to pay',
                    style: TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Year Group Selector
                  Text(
                    'Year Group',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (isLoadingYearGroups)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF334155)),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (yearGroups.isEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF334155)),
                      ),
                      child: Text(
                        'No year groups available',
                        style: TextStyle(color: Color(0xFF94a3b8)),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedYearGroupId,
                          isExpanded: true,
                          dropdownColor: Color(0xFF0f172a),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          items: yearGroups.map((group) {
                            return DropdownMenuItem<String>(
                              value: group['id'],
                              child: Text(
                                group['name'],
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedYearGroupId = newValue;
                                final selected = yearGroups.firstWhere((g) => g['id'] == newValue);
                                selectedYearGroupName = selected['name'];
                              });
                              _fetchDuesForYearGroup(newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 20),

                  // Dues Item Dropdown
                  Text(
                    'Dues Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (isLoadingDues)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF334155)),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (duesItems.isEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF334155)),
                      ),
                      child: Text(
                        'No dues items available for this year group',
                        style: TextStyle(color: Color(0xFF94a3b8)),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDuesId,
                          isExpanded: true,
                          dropdownColor: Color(0xFF0f172a),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          items: duesItems.map((dues) {
                            return DropdownMenuItem<String>(
                              value: dues['id'],
                              child: Text(
                                '${dues['title']} - ${dues['currency']}${dues['amount'].toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDuesId = newValue;
                              final selected = duesItems.firstWhere((d) => d['id'] == newValue);
                              selectedDuesTitle = selected['title'];
                              selectedDuesAmount = selected['amount'];
                            });
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 24),

                  // Amount Display
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF0f172a),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount:',
                          style: TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          selectedDuesAmount != null 
                              ? 'GH₵${selectedDuesAmount!.toStringAsFixed(2)}'
                              : 'GH₵0.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Error Message
                  if (errorMessage != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Footer Buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF334155),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessingPayment ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isProcessingPayment || selectedDuesAmount == null) 
                          ? null 
                          : _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: odaPrimary,
                        disabledBackgroundColor: odaPrimary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isProcessingPayment
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Proceed to Payment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
