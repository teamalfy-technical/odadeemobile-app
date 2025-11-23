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
      // Get user data for payment request
      var firstName = await storage.read(key: 'user_first_name') ?? '';
      var lastName = await storage.read(key: 'user_last_name') ?? '';
      var email = await storage.read(key: 'user_email') ?? '';
      
      // If user data is missing, try to refresh from API
      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
        print('User data missing from storage, fetching from API...');
        try {
          final userData = await authService.getCurrentUser();
          firstName = userData['firstName'] ?? userData['first_name'] ?? '';
          lastName = userData['lastName'] ?? userData['last_name'] ?? '';
          email = userData['email'] ?? '';
          
          // Store refreshed data for future use
          if (firstName.isNotEmpty && lastName.isNotEmpty && email.isNotEmpty) {
            await storage.write(key: 'user_first_name', value: firstName);
            await storage.write(key: 'user_last_name', value: lastName);
            await storage.write(key: 'user_email', value: email);
            print('Refreshed user data saved to storage');
          }
        } catch (e) {
          print('Failed to fetch user data: $e');
        }
      }
      
      // Validate required fields
      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
        throw Exception('User information incomplete. Please try logging in again.');
      }
      
      // Map payment types to backend product codes
      final productCode = paymentType == 'dues' ? 'YEAR_GROUP_DUES' : paymentType;
      
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
          final paymentUrl = data['paymentUrl'];
          
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
