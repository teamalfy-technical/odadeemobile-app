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
      // First try cached user data, then fetch from API
      print('Getting user data for payment...');
      Map<String, dynamic>? userData;
      
      // Try cached data first
      userData = await authService.getCachedUser();
      print('Cached user data: $userData');
      
      // If no cached data or missing required fields, try fetching from API
      if (userData == null || 
          (userData['firstName']?.toString().isEmpty ?? true) ||
          (userData['email']?.toString().isEmpty ?? true)) {
        print('Cached data incomplete, fetching from API...');
        try {
          userData = await authService.getCurrentUser();
          print('User data from API: $userData');
        } catch (e) {
          print('API fetch failed: $e');
          // If API fails and we have partial cached data, use it
          if (userData == null) {
            // Try to get individual cached fields
            final cachedFirstName = await storage.read(key: 'user_first_name');
            final cachedLastName = await storage.read(key: 'user_last_name');
            final cachedEmail = await storage.read(key: 'user_email');
            
            if (cachedFirstName != null && cachedLastName != null && cachedEmail != null) {
              userData = {
                'firstName': cachedFirstName,
                'lastName': cachedLastName,
                'email': cachedEmail,
              };
              print('Using individually cached fields: $userData');
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
      
      print('Extracted - firstName: "$firstName", lastName: "$lastName", email: "$email"');
      
      // Validate required fields
      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
        print('ERROR: Missing fields - firstName: ${firstName.isEmpty}, lastName: ${lastName.isEmpty}, email: ${email.isEmpty}');
        throw Exception('User information incomplete. Please update your profile with your name and email, then try again.');
      }
      
      // Map payment types to backend product codes
      final productCode = paymentType == 'dues' ? 'year_group_dues' : paymentType;
      
      print('Creating payment: productCode=$productCode, amount=$amount, yearGroupId=$yearGroupId');
      print('User info: firstName=$firstName, lastName=$lastName, email=$email');
      
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
      
      print('=== PAYMENT API REQUEST ===');
      print('Endpoint: /api/payments/create');
      print('Request body: $requestBody');
      
      final response = await authService.authenticatedRequest(
        'POST',
        '/api/payments/create',
        body: requestBody,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
