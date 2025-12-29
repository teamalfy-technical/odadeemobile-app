import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odadee/Screens/Payment/payment_screen.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/services/payment_service.dart';

class ProjectContributionModal extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ProjectContributionModal({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<ProjectContributionModal> createState() =>
      _ProjectContributionModalState();
}

class _ProjectContributionModalState extends State<ProjectContributionModal> {
  List<Map<String, dynamic>> yearGroups = [];
  String? selectedYearGroupId;
  String? selectedYearGroupName;

  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoadingYearGroups = true;
  bool isProcessingPayment = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchYearGroups();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
          yearGroups = groups
              .map((g) => {
                    'id': g['id'],
                    'name': g['name'] ?? 'Class of ${g['year']}',
                    'year': g['year'] is int
                        ? g['year']
                        : int.tryParse(g['year'].toString()) ?? 0,
                  })
              .toList();

          // Sort year groups ascending
          yearGroups
              .sort((a, b) => (a['year'] as int).compareTo(b['year'] as int));

          isLoadingYearGroups = false;

          // Auto-select first year group if available
          if (yearGroups.isNotEmpty) {
            // Optional selection logic
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

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedYearGroupId == null) {
      setState(() {
        errorMessage = 'Please select your Year Group';
      });
      return;
    }

    final amountStr = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = 'Please enter a valid amount';
      });
      return;
    }

    try {
      setState(() {
        isProcessingPayment = true;
        errorMessage = null;
      });

      final paymentService = PaymentService();
      // Using 'project' as payment type as required by backend
      final paymentUrl = await paymentService.createPayment(
        paymentType: 'project',
        amount: amount,
        yearGroupId: selectedYearGroupId!,
        projectId: widget.projectId,
        description: 'Contribution to: ${widget.projectTitle}',
      );

      setState(() {
        isProcessingPayment = false;
      });

      if (!mounted) return;

      // Open payment screen
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(paymentUrl: paymentUrl),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        Navigator.pop(context, true); // Close modal and return success
      } else if (result == false) {
        // Just show error but keep modal open optionally, or close?
        // Usually better to let user try again if they cancelled.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled or failed. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
        errorMessage =
            'Payment error: ${e.toString().replaceAll("Exception:", "").trim()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
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
                    const Text(
                      'Contribute to Project',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.projectTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),

                      // Year Group Selector
                      const Text(
                        'Your Year Group',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingYearGroups)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0f172a),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(odaPrimary),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      else if (yearGroups.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0f172a),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: const Text(
                            'No year groups available',
                            style: TextStyle(color: Color(0xFF94a3b8)),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0f172a),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedYearGroupId,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF0f172a),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white70),
                              hint: const Text(
                                'Select Year Group',
                                style: TextStyle(color: Colors.grey),
                              ),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                              items: yearGroups.map((group) {
                                return DropdownMenuItem<String>(
                                  value: group['id'],
                                  child: Text(
                                    group['name'],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedYearGroupId = newValue;
                                    final selected = yearGroups
                                        .firstWhere((g) => g['id'] == newValue);
                                    selectedYearGroupName = selected['name'];
                                    // Clear error if resolved
                                    if (errorMessage ==
                                        'Please select your Year Group') {
                                      errorMessage = null;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Amount Input
                      const Text(
                        'Amount (GHS)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF0f172a),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'GH₵',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF334155)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF334155)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: odaPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          return null;
                        },
                      ),

                      // Error Message
                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
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
                        onPressed: isProcessingPayment
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isProcessingPayment ? null : _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: odaPrimary,
                          disabledBackgroundColor: odaPrimary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isProcessingPayment
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Make Payment',
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
      ),
    );
  }
}
