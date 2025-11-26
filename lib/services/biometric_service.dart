import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  /// Check if biometric is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if device has any biometric enrolled
  Future<bool> hasBiometricEnrolled() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking biometric enrollment: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometric
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Enable biometric login for a user
  Future<void> enableBiometricLogin(String email, String password) async {
    try {
      // Authenticate user first
      final isAuthenticated = await authenticate();
      
      if (isAuthenticated) {
        // Store credentials securely after biometric verification
        await _storage.write(
          key: 'biometric_email_$email',
          value: email,
        );
        await _storage.write(
          key: 'biometric_enabled',
          value: 'true',
        );
        debugPrint('Biometric login enabled for user: $email');
      }
    } catch (e) {
      debugPrint('Error enabling biometric login: $e');
      rethrow;
    }
  }

  /// Disable biometric login
  Future<void> disableBiometricLogin() async {
    try {
      await _storage.delete(key: 'biometric_enabled');
      debugPrint('Biometric login disabled');
    } catch (e) {
      debugPrint('Error disabling biometric login: $e');
      rethrow;
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricLoginEnabled() async {
    try {
      final value = await _storage.read(key: 'biometric_enabled');
      return value == 'true';
    } catch (e) {
      debugPrint('Error checking biometric login status: $e');
      return false;
    }
  }

  /// Get the email stored for biometric login
  Future<String?> getBiometricEmail() async {
    try {
      final keys = await _storage.readAll();
      // Find the key that starts with 'biometric_email_'
      for (var entry in keys.entries) {
        if (entry.key.startsWith('biometric_email_')) {
          return entry.value;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting biometric email: $e');
      return null;
    }
  }

  /// Clear all biometric data
  Future<void> clearBiometricData() async {
    try {
      final keys = await _storage.readAll();
      for (var key in keys.keys) {
        if (key.startsWith('biometric_')) {
          await _storage.delete(key: key);
        }
      }
      debugPrint('Biometric data cleared');
    } catch (e) {
      debugPrint('Error clearing biometric data: $e');
      rethrow;
    }
  }
}
