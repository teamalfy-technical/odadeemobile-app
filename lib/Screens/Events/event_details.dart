import 'package:flutter/material.dart';
import 'package:odadee/models/event.dart';
import 'package:odadee/config/api_config.dart';
import 'package:odadee/constants.dart';
import 'package:intl/intl.dart';
import 'package:odadee/components/event_image_widget.dart';
import 'package:odadee/services/event_service.dart';
import 'package:odadee/services/payment_service.dart';
import 'package:odadee/services/auth_service.dart';
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
  
  bool _isRegistering = false;
  bool _isRegistered = false;
  int _ticketCount = 1;

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(date);
  }

  String _formatDateShort(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
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
        String yearGroupId = event!.yearGroupId ?? '';
        if (yearGroupId.isEmpty) {
          final userData = await _authService.getCurrentUser();
          yearGroupId = userData['yearGroupId']?.toString() ?? 
                       userData['yearGroup']?.toString() ?? 
                       userData['graduationYear']?.toString() ?? '';
        }
        
        final paymentUrl = await _paymentService.createPayment(
          paymentType: 'event',
          amount: totalAmount,
          yearGroupId: yearGroupId,
          eventId: event!.id,
          description: 'Ticket purchase for ${event!.title} (${_ticketCount} ticket${_ticketCount > 1 ? 's' : ''})',
        );
        
        setState(() {
          _isRegistering = false;
        });
        
        _showPaymentConfirmation(paymentUrl, totalAmount);
      } else {
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
      setState(() {
        _isRegistering = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              'Your ticket purchase of GH₵ ${amount.toStringAsFixed(2)} is ready.',
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
                  _buildPaymentInfoRow('Event', event!.title),
                  SizedBox(height: 8),
                  _buildPaymentInfoRow('Tickets', '$_ticketCount'),
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

  void _showSuccessDialog(EventRegistration registration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1e293b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10b981), size: 28),
            SizedBox(width: 12),
            Text(
              'Registration Successful!',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have successfully registered for this event.',
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
                  _buildInfoRow('Event', event!.title),
                  SizedBox(height: 8),
                  _buildInfoRow('Tickets', '${registration.ticketsPurchased}'),
                  if (registration.totalAmount > 0) ...[
                    SizedBox(height: 8),
                    _buildInfoRow('Total', 'GH₵ ${registration.totalAmount.toStringAsFixed(2)}'),
                  ],
                  SizedBox(height: 8),
                  _buildInfoRow('Status', registration.paymentStatus.toUpperCase()),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "You'll receive an email confirmation with event details.",
              style: TextStyle(color: Color(0xFF64748b), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: TextStyle(color: Color(0xFF2563eb))),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  void _showTicketSelector() {
    if (event == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1e293b),
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
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  event!.title,
                  style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                ),
                SizedBox(height: 24),
                
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0f172a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Number of Tickets',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _ticketCount > 1 ? () {
                              setModalState(() => _ticketCount--);
                              setState(() {});
                            } : null,
                            icon: Icon(Icons.remove_circle_outline),
                            color: _ticketCount > 1 ? Color(0xFF2563eb) : Color(0xFF64748b),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFF1e293b),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_ticketCount',
                              style: TextStyle(
                                color: Colors.white,
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
                            color: Color(0xFF2563eb),
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
                      color: Color(0xFF0f172a),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          'GH₵ ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Color(0xFFf4d03f),
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
                      backgroundColor: Color(0xFF2563eb),
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
    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Event Details', style: TextStyle(color: Colors.black)),
        ),
        body: Center(child: Text('Event not found')),
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
          'Event Details',
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
                color: Color(0xFF1e293b),
                child: Center(
                  child: Icon(
                    Icons.event,
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: event!.status == 'upcoming'
                              ? Color(0xFF2563eb).withOpacity(0.2)
                              : Color(0xFF64748b).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event!.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: event!.status == 'upcoming' 
                                ? Color(0xFF2563eb) 
                                : Color(0xFF94a3b8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_isRegistered) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF10b981).withOpacity(0.2),
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF334155),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFF2563eb), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date & Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatDate(event!.startDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
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
                      color: Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF334155),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFF2563eb), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                event!.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
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
                        color: Color(0xFF1e293b),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF334155),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.confirmation_number, color: Color(0xFF2563eb), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ticket Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94a3b8),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'GH₵ ${event!.ticketPrice!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    event!.description,
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
                      onPressed: _isRegistered ? null : (_isRegistering ? null : _showTicketSelector),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRegistered ? Color(0xFF10b981) : Color(0xFF2563eb),
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
