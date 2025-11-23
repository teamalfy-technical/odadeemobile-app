import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odadee/config/api_config.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

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
      final accessToken = await storage.read(key: 'access_token');
      
      if (accessToken == null) {
        throw Exception('Not authenticated');
      }

      final dio = Dio();
      
      // Map payment types to backend product codes
      final productCode = paymentType == 'dues' ? 'YEAR_GROUP_DUES' : paymentType;
      
      print('Creating payment: productCode=$productCode, amount=$amount, yearGroupId=$yearGroupId');
      
      final response = await dio.post(
        '${ApiConfig.baseUrl}/payments/create',
        data: {
          'paymentType': productCode,
          'amount': amount,
          'yearGroupId': yearGroupId,
          if (description != null) 'description': description,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (projectId != null) 'projectId': projectId,
          if (eventId != null) 'eventId': eventId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final paymentUrl = response.data['paymentUrl'];
        if (paymentUrl == null || paymentUrl.isEmpty) {
          print('Payment response: ${response.data}');
          throw Exception('Payment URL not found in response');
        }
        print('Payment created successfully: $paymentUrl');
        return paymentUrl;
      } else {
        print('Payment creation failed with status ${response.statusCode}: ${response.data}');
        throw Exception('Failed to create payment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Payment creation failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Payment creation error: $e');
    }
  }
}
