import 'package:flutter/material.dart';
import 'package:odadee/models/event.dart';
import 'package:odadee/config/api_config.dart';
import 'package:odadee/constants.dart';
import 'package:intl/intl.dart';
import 'package:odadee/components/event_image_widget.dart';
import 'package:odadee/services/event_service.dart';
import 'package:odadee/services/payment_service.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/services/year_group_service.dart';
import 'package:odadee/services/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final dynamic data;

  const EventDetailsScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event? get event => widget.data is Event ? widget.data as Event : null;
  final EventService _eventService = EventService();
  final PaymentService _paymentService = PaymentService();
  final AuthService _authService = AuthService();
  final YearGroupService _yearGroupService = YearGroupService();
  
  bool _isRegistering = false;
  bool _isRegistered = false;
  int _ticketCount = 1;

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(date);
  }

  Future<void> _handleRegistration() async {
    if (event == null) return;
    
    final ticketPrice = event!.ticketPrice ?? 0;
    final totalAmount = ticketPrice * _ticketCount;
    
    setState(() {
      _isRegistering = true;
    });

    try {
      if (ticketPrice > 0) {
        print('=== EVENT PAYMENT DEBUG ===');
        print('Event ID: ${event!.id}');
        print('Event yearGroupId: ${event!.yearGroupId}');
        print('Ticket count: $_ticketCount');
        print('Total amount: $totalAmount');
        
        String yearGroupId = event!.yearGroupId ?? '';
        if (yearGroupId.isEmpty) {
          print('Event has no yearGroupId, fetching user year group...');
          
          // Get the actual year group UUID from YearGroupService
          try {
            final yearGroup = await _yearGroupService.getUserYearGroup();
            if (yearGroup != null) {
              yearGroupId = yearGroup.id;
              print('Got year group from service: id=${yearGroup.id}, name=${yearGroup.name}');
            }
          } catch (e) {
            print('Failed to get year group from service: $e');
            // Fallback: try to get from user data
            Map<String, dynamic>? userData = await _authService.getCachedUser();
            if (userData == null) {
              try {
                userData = await _authService.getCurrentUser();
              } catch (e) {
                print('API fetch also failed: $e');
              }
            }
            
            // Check if user data has a yearGroupId (UUID)
            yearGroupId = userData?['yearGroupId']?.toString() ?? '';
            if (yearGroupId.isEmpty && userData?['yearGroup'] is Map) {
              yearGroupId = (userData!['yearGroup'] as Map)['id']?.toString() ?? '';
            }
          }
          print('Resolved yearGroupId: "$yearGroupId"');
        }
        
        if (yearGroupId.isEmpty) {
          throw Exception('Could not determine year group. Please update your profile with your graduation year.');
        }
        
        print('Final yearGroupId: $yearGroupId');
        print('Calling payment service...');
        
        final paymentUrl = await _paymentService.createPayment(
          paymentType: 'event',
          amount: totalAmount,
          yearGroupId: yearGroupId,
          eventId: event!.id,
          description: 'Ticket purchase for ${event!.title} ($_ticketCount ticket${_ticketCount > 1 ? 's' : ''})',
        );
        
        print('Payment URL received: $paymentUrl');
        
        setState(() {
          _isRegistering = false;
        });
        
        _showPaymentConfirmation(paymentUrl, totalAmount);
      } else {
        // Free event - register directly
        print('Free event - registering directly...');
        final registration = await _eventService.registerForEvent(
          eventId: event!.id,
          ticketsPurchased: _ticketCount,
        );
        
        setState(() {
          _isRegistered = true;
          _isRegistering = false;
        });
        
        _showSuccessDialog(registration);
      }
    } catch (e) {
      print('Event registration error: $e');
      setState(() {
        _isRegistering = false;
      });
      
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentConfirmation(String paymentUrl, double amount) {
    final cardColor = AppColors.cardColor(context);
    final surfaceColor = AppColors.surfaceColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.payment, color: odaPrimary, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Complete Payment',
                style: TextStyle(color: textColor, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ticket purchase of GH₵ ${amount.toStringAsFixed(2)} is ready.',
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
                  _buildPaymentInfoRow('Event', event!.title, textColor, subtitleColor),
                  SizedBox(height: 8),
                  _buildPaymentInfoRow('Tickets', '$_ticketCount', textColor, subtitleColor),
                  SizedBox(height: 8),
                  _buildPaymentInfoRow('Amount', 'GH₵ ${amount.toStringAsFixed(2)}', textColor, subtitleColor),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Click "Pay Now" to open the payment page. After completing payment, return here and tap "I\'ve Completed Payment".',
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
              final uri = Uri.parse(paymentUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                
                // Close current dialog and show payment completion dialog
                Navigator.pop(context);
                _showPaymentCompletionDialog(amount);
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
  
  void _showPaymentCompletionDialog(double amount) {
    final cardColor = AppColors.cardColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    
    bool isConfirming = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle_outline, color: odaSecondary, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment Status',
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have you completed your payment of GH₵ ${amount.toStringAsFixed(2)} for "${event!.title}"?',
                  style: TextStyle(color: subtitleColor),
                ),
                SizedBox(height: 16),
                Text(
                  'If you\'ve completed the payment, tap "I\'ve Completed Payment" to complete your registration.',
                  style: TextStyle(color: subtitleColor.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isConfirming ? null : () {
                  Navigator.pop(dialogContext);
                },
                child: Text('Not Yet', style: TextStyle(color: subtitleColor)),
              ),
              ElevatedButton(
                onPressed: isConfirming ? null : () async {
                  setDialogState(() => isConfirming = true);
                  
                  try {
                    print('Completing event registration after payment...');
                    
                    // Call the registration endpoint to complete registration
                    final registration = await _eventService.registerForEvent(
                      eventId: event!.id,
                      ticketsPurchased: _ticketCount,
                    );
                    
                    print('Registration successful: ${registration.id}');
                    
                    Navigator.pop(dialogContext);
                    
                    if (!mounted) return;
                    
                    setState(() {
                      _isRegistered = true;
                    });
                    
                    // Show success dialog
                    _showSuccessDialog(registration);
                  } catch (e) {
                    print('Registration error: $e');
                    
                    setDialogState(() => isConfirming = false);
                    
                    if (!mounted) return;
                    
                    String errorMessage = e.toString();
                    if (errorMessage.startsWith('Exception: ')) {
                      errorMessage = errorMessage.substring(11);
                    }
                    
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Expanded(child: Text('Registration failed: $errorMessage')),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: isConfirming 
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text("I've Completed Payment", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
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

  void _showSuccessDialog(EventRegistration registration) {
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
            Icon(Icons.check_circle, color: Color(0xFF10b981), size: 28),
            SizedBox(width: 12),
            Text(
              'Registration Successful!',
              style: TextStyle(color: textColor, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have successfully registered for this event.',
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
                  _buildInfoRow('Event', event!.title, textColor, subtitleColor),
                  SizedBox(height: 8),
                  _buildInfoRow('Tickets', '${registration.ticketsPurchased}', textColor, subtitleColor),
                  if (registration.totalAmount > 0) ...[
                    SizedBox(height: 8),
                    _buildInfoRow('Total', 'GH₵ ${registration.totalAmount.toStringAsFixed(2)}', textColor, subtitleColor),
                  ],
                  SizedBox(height: 8),
                  _buildInfoRow('Status', registration.paymentStatus.toUpperCase(), textColor, subtitleColor),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "You'll receive an email confirmation with event details.",
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: TextStyle(color: odaPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor, Color subtitleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: subtitleColor, fontSize: 13)),
        Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  void _showTicketSelector() {
    if (event == null) return;
    
    final cardColor = AppColors.cardColor(context);
    final surfaceColor = AppColors.surfaceColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final pricePerTicket = event!.ticketPrice ?? 0;
          final totalPrice = pricePerTicket * _ticketCount;
          
          return Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Tickets',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  event!.title,
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                SizedBox(height: 24),
                
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Number of Tickets',
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _ticketCount > 1 ? () {
                              setModalState(() => _ticketCount--);
                              setState(() {});
                            } : null,
                            icon: Icon(Icons.remove_circle_outline),
                            color: _ticketCount > 1 ? odaPrimary : mutedColor,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_ticketCount',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setModalState(() => _ticketCount++);
                              setState(() {});
                            },
                            icon: Icon(Icons.add_circle_outline),
                            color: odaPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (pricePerTicket > 0) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                        Text(
                          'GH₵ ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: odaSecondary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isRegistering ? null : () {
                      Navigator.pop(context);
                      _handleRegistration();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: odaPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isRegistering
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            pricePerTicket > 0 
                                ? 'Confirm & Pay GH₵ ${totalPrice.toStringAsFixed(2)}'
                                : 'Confirm Registration',
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppColors.isDark(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = AppColors.cardColor(context);
    final borderColor = AppColors.borderColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    
    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Event Details'),
        ),
        body: Center(child: Text('Event not found', style: TextStyle(color: textColor))),
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
          'Event Details',
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
            if (event!.bannerUrl != null && event!.bannerUrl!.isNotEmpty)
              EventImageWidget(
                imageUrl: event!.bannerUrl!.startsWith('http')
                    ? event!.bannerUrl!
                    : '${ApiConfig.baseUrl}/${event!.bannerUrl}',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: cardColor,
                child: Center(
                  child: Icon(
                    Icons.event,
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: event!.status == 'upcoming'
                              ? odaPrimary.withAlpha(51)
                              : mutedColor.withAlpha(51),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event!.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: event!.status == 'upcoming' 
                                ? odaPrimary 
                                : subtitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_isRegistered) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF10b981).withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, color: Color(0xFF10b981), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'REGISTERED',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF10b981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  Text(
                    event!.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: odaPrimary, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date & Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtitleColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatDate(event!.startDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: odaPrimary, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtitleColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                event!.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (event!.ticketPrice != null && event!.ticketPrice! > 0) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.confirmation_number, color: odaPrimary, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ticket Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtitleColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'GH₵ ${event!.ticketPrice!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 24),
                  
                  Text(
                    'About this event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    event!.description,
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
                      onPressed: _isRegistered ? null : (_isRegistering ? null : _showTicketSelector),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRegistered ? Color(0xFF10b981) : odaPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isRegistering
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isRegistered) ...[
                                  Icon(Icons.check, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                ],
                                Text(
                                  _isRegistered ? 'Already Registered' : 'Register for Event',
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
