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
      // Get user data from API (AuthService now returns normalized data)
      print('Fetching user data from API...');
      final userData = await authService.getCurrentUser();
      
      print('User data from API: $userData');
      
      final firstName = userData['firstName']?.toString() ?? 
                        userData['first_name']?.toString() ?? '';
      final lastName = userData['lastName']?.toString() ?? 
                       userData['last_name']?.toString() ?? '';
      final email = userData['email']?.toString() ?? '';
      
      print('Extracted - firstName: "$firstName", lastName: "$lastName", email: "$email"');
      
      // Validate required fields
      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
        print('ERROR: Missing fields - firstName: ${firstName.isEmpty}, lastName: ${lastName.isEmpty}, email: ${email.isEmpty}');
        throw Exception('User information incomplete. Please ensure your profile has firstName, lastName, and email filled in.');
      }
      
      // Map payment types to backend product codes
      final productCode = paymentType == 'dues' ? 'year_group_dues' : paymentType;
      
      print('Creating payment: productCode=$productCode, amount=$amount, yearGroupId=$yearGroupId');
      print('User info: firstName=$firstName, lastName=$lastName, email=$email');
      
      final response = await authService.authenticatedRequest(
        'POST',
        '/api/payments/create',
        body: {
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
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          
          // Extract payment URL from nested payment object
          final paymentUrl = data['payment']?['paymentUrl'] ?? data['paymentUrl'];
          
          if (paymentUrl == null || paymentUrl.isEmpty) {
            print('Payment response: ${response.body}');
            throw Exception('Payment URL not found in response');
          }
          
          print('Payment created successfully: $paymentUrl');
          return paymentUrl;
        } catch (e) {
          print('Failed to parse payment response: ${response.body}');
          throw Exception('Invalid payment response format');
        }
      } else {
        print('Payment creation failed with status ${response.statusCode}: ${response.body}');
        
        // Try to parse error message from JSON, fall back to raw body
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Payment failed: ${response.statusCode}');
        } catch (e) {
          // Response is not JSON, show raw body
          throw Exception('Payment failed (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      print('Payment creation error: $e');
      rethrow;
    }
  }
}
