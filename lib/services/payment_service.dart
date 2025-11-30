import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odadee/services/auth_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final authService = AuthService();
  final storage = const FlutterSecureStorage();

  Future<String> createPayment({
    required String paymentType,
    required double amount,
    required String yearGroupId,
    String? description,
    String? phoneNumber,
    String? projectId,
    String? eventId,
  }) async {
    try {
      Map<String, dynamic>? userData;
      
      userData = await authService.getCachedUser();
      
      if (userData == null || 
          (userData['firstName']?.toString().isEmpty ?? true) ||
          (userData['email']?.toString().isEmpty ?? true)) {
        try {
          userData = await authService.getCurrentUser();
        } catch (e) {
          if (userData == null) {
            final cachedFirstName = await storage.read(key: 'user_first_name');
            final cachedLastName = await storage.read(key: 'user_last_name');
            final cachedEmail = await storage.read(key: 'user_email');
            
            if (cachedFirstName != null && cachedLastName != null && cachedEmail != null) {
              userData = {
                'firstName': cachedFirstName,
                'lastName': cachedLastName,
                'email': cachedEmail,
              };
            } else {
              throw Exception('Your session has expired. Please log out and log in again to continue with the payment.');
            }
          }
        }
      }
      
      final firstName = userData?['firstName']?.toString() ?? 
                        userData?['first_name']?.toString() ?? '';
      final lastName = userData?['lastName']?.toString() ?? 
                       userData?['last_name']?.toString() ?? '';
      final email = userData?['email']?.toString() ?? '';
      
      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
        throw Exception('User information incomplete. Please update your profile with your name and email, then try again.');
      }
      
      final productCode = paymentType == 'dues' ? 'year_group_dues' : paymentType;
      
      final requestBody = {
        'paymentType': productCode,
        'amount': amount,
        'yearGroupId': yearGroupId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (description != null) 'description': description,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (projectId != null) 'projectId': projectId,
        if (eventId != null) 'eventId': eventId,
      };
      
      final response = await authService.authenticatedRequest(
        'POST',
        '/api/payments/create',
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final paymentUrl = data['payment']?['paymentUrl'] ?? data['paymentUrl'];
          
          if (paymentUrl == null || paymentUrl.isEmpty) {
            throw Exception('Payment URL not found in response');
          }
          
          return paymentUrl;
        } catch (e) {
          throw Exception('Invalid payment response format');
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Payment failed: ${response.statusCode}');
        } catch (e) {
          throw Exception('Payment failed (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
