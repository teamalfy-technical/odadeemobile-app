import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:odadee/config/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      final deviceInfo = await _getDeviceInfo();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'deviceInfo': {
            'deviceId': deviceId,
            'deviceName': deviceInfo['deviceName'],
            'deviceType': deviceInfo['deviceType'],
            'deviceModel': deviceInfo['deviceModel'],
            'osName': deviceInfo['osName'],
            'osVersion': deviceInfo['osVersion'],
            'appVersion': ApiConfig.appVersion,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeTokens(data['accessToken'], data['refreshToken']);
        await _storeUser(data['user']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String yearGroup,
    String? middleName,
    String? username,
    String? country,
  }) async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      final deviceInfo = await _getDeviceInfo();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/mobile/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'yearGroup': yearGroup,
          if (middleName != null) 'middleName': middleName,
          if (username != null) 'username': username,
          if (country != null) 'country': country,
          'deviceInfo': {
            'deviceId': deviceId,
            'deviceName': deviceInfo['deviceName'],
            'deviceType': deviceInfo['deviceType'],
            'deviceModel': deviceInfo['deviceModel'],
            'osName': deviceInfo['osName'],
            'osVersion': deviceInfo['osVersion'],
            'appVersion': ApiConfig.appVersion,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null && data['refreshToken'] != null) {
          await _storeTokens(data['accessToken'], data['refreshToken']);
          await _storeUser(data['user']);
        }
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<String> refreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'access_token', value: data['accessToken']);
        return data['accessToken'];
      } else {
        await _clearStorage();
        throw Exception('Session expired, please login again');
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestMagicLink(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/magic-link/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Magic link sent to your email'
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to send magic link'
        };
      }
    } catch (e) {
      debugPrint('Magic link request error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> verifyMagicLink(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/magic-link/validate/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // For web, this creates a session cookie (no JWT tokens returned)
        // For mobile apps, use password login instead
        if (data['user'] != null) {
          await _storeUser(data['user']);

          // For web platform: Store a flag to indicate authenticated via session cookie
          if (kIsWeb) {
            await storage.write(key: 'access_token', value: 'web_session_auth');
            await storage.write(key: 'auth_type', value: 'web_session');
          }

          return {'success': true, 'user': data['user']};
        } else {
          throw Exception('No user data returned from magic link');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid or expired magic link');
      }
    } catch (e) {
      debugPrint('Magic link verification error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');

      if (refreshToken != null) {
        try {
          await http.post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          );
        } catch (e) {
          debugPrint('Logout API error: $e');
        }
      }

      await _clearStorage();
    } catch (e) {
      debugPrint('Logout error: $e');
      await _clearStorage();
    }
  }

  Future<void> logoutAllDevices() async {
    try {
      final accessToken = await storage.read(key: 'access_token');

      if (accessToken != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutAllEndpoint}'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );
      }

      await _clearStorage();
    } catch (e) {
      debugPrint('Logout all devices error: $e');
      await _clearStorage();
    }
  }

  Future<Map<String, dynamic>> changePassword({
    String? currentPassword,
    required String newPassword,
  }) async {
    try {
      final body = <String, dynamic>{
        'newPassword': newPassword,
      };
      
      if (currentPassword != null && currentPassword.isNotEmpty) {
        body['currentPassword'] = currentPassword;
      }

      final response = await authenticatedRequest(
        'POST',
        '/api/auth/change-password',
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await authenticatedRequest('GET', ApiConfig.meEndpoint);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // API returns {user: {...}} structure, extract the nested user object
        final userData = responseData['user'] ?? responseData;
        await _storeUser(userData);
        return userData;
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      debugPrint('Get current user error: $e');
      rethrow;
    }
  }

  Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    String? accessToken = await storage.read(key: 'access_token');
    final authType = await storage.read(key: 'auth_type');

    // For web session auth, don't use JWT Bearer token - rely on cookies
    if (kIsWeb && authType == 'web_session') {
      accessToken = null; // Browser will send session cookie automatically
    }

    final response = await _makeRequest(
      method,
      endpoint,
      accessToken,
      body,
      additionalHeaders,
    );

    // For web session auth, 401 means session expired - don't try to refresh
    if (response.statusCode == 401) {
      if (kIsWeb && authType == 'web_session') {
        await _clearStorage();
        throw Exception('Session expired, please login again');
      }

      // For JWT auth, try to refresh token
      try {
        accessToken = await refreshToken();
        return await _makeRequest(
          method,
          endpoint,
          accessToken,
          body,
          additionalHeaders,
        );
      } catch (e) {
        throw Exception('Authentication failed, please login again');
      }
    }

    return response;
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint,
    String? token,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (additionalHeaders != null) ...additionalHeaders,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      case 'PATCH':
        return await http.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await storage.read(key: 'device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await storage.write(key: 'device_id', value: deviceId);
    }
    return deviceId;
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    if (kIsWeb) {
      return {
        'deviceName': 'Web Browser',
        'deviceType': 'Web',
        'deviceModel': 'Browser',
        'osName': 'Web',
        'osVersion': 'N/A',
      };
    }

    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'deviceName': androidInfo.model,
          'deviceType': 'Android',
          'deviceModel': androidInfo.model,
          'osName': 'Android',
          'osVersion': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'deviceName': iosInfo.name,
          'deviceType': 'iOS',
          'deviceModel': iosInfo.model,
          'osName': 'iOS',
          'osVersion': iosInfo.systemVersion,
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    return {
      'deviceName': 'Unknown',
      'deviceType': 'Unknown',
      'deviceModel': 'Unknown',
      'osName': 'Unknown',
      'osVersion': 'Unknown',
    };
  }

  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> _storeUser(Map<String, dynamic> user) async {
    await storage.write(key: 'user_data', value: jsonEncode(user));

    await storage.write(key: 'user_id', value: user['id']?.toString() ?? '');
    await storage.write(
        key: 'user_email', value: user['email']?.toString() ?? '');
    await storage.write(
        key: 'user_first_name', value: user['firstName']?.toString() ?? '');
    await storage.write(
        key: 'user_last_name', value: user['lastName']?.toString() ?? '');
    await storage.write(
        key: 'user_role', value: user['role']?.toString() ?? '');
  }

  Future<void> _clearStorage() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_data');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'user_email');
    await storage.delete(key: 'user_first_name');
    await storage.delete(key: 'user_last_name');
    await storage.delete(key: 'user_role');
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await storage.read(key: 'access_token');
    return accessToken != null;
  }

  Future<Map<String, dynamic>?> getCachedUser() async {
    final userData = await storage.read(key: 'user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }

  /// Store credentials for biometric login
  Future<void> storeBiometricCredentials(String email, String password) async {
    try {
      await storage.write(key: 'biometric_email', value: email);
      await storage.write(key: 'biometric_password', value: password);
      await storage.write(key: 'biometric_enabled', value: 'true');
      debugPrint('Biometric credentials stored');
    } catch (e) {
      debugPrint('Error storing biometric credentials: $e');
      rethrow;
    }
  }

  /// Retrieve stored credentials for biometric login
  Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final email = await storage.read(key: 'biometric_email');
      final password = await storage.read(key: 'biometric_password');
      
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving biometric credentials: $e');
      return null;
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricLoginEnabled() async {
    try {
      final enabled = await storage.read(key: 'biometric_enabled');
      return enabled == 'true';
    } catch (e) {
      debugPrint('Error checking biometric login status: $e');
      return false;
    }
  }

  /// Clear biometric login data
  Future<void> clearBiometricLogin() async {
    try {
      await storage.delete(key: 'biometric_email');
      await storage.delete(key: 'biometric_password');
      await storage.delete(key: 'biometric_enabled');
      debugPrint('Biometric login data cleared');
    } catch (e) {
      debugPrint('Error clearing biometric login: $e');
      rethrow;
    }
  }

  /// Request password reset via email
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset link sent to your email. Please check your inbox.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Email not found. Please check and try again.',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to send password reset link',
        };
      }
    } catch (e) {
      debugPrint('Password reset request error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
      };
    }
  }

  /// Reset password using token
  Future<Map<String, dynamic>> resetPasswordWithToken({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successfully. Please log in with your new password.',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Invalid or expired reset link. Please request a new one.',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      debugPrint('Password reset error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  /// Request magic link for passwordless login
  Future<Map<String, dynamic>> requestMagicLinkLogin(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/magic-link/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Magic link sent to your email. Click the link to log in.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Email not found. Please check and try again.',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to send magic link',
        };
      }
    } catch (e) {
      debugPrint('Magic link request error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  /// Verify magic link token and set password
  Future<Map<String, dynamic>> setPasswordWithMagicLink({
    required String token,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/magic-link/set-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null && data['refreshToken'] != null) {
          await _storeTokens(data['accessToken'], data['refreshToken']);
          if (data['user'] != null) {
            await _storeUser(data['user']);
          }
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Password set successfully. You are now logged in.',
          'user': data['user'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Invalid or expired magic link. Please request a new one.',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to set password',
        };
      }
    } catch (e) {
      debugPrint('Set password with magic link error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }
}
