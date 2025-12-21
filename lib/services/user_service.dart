import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odadee/services/auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getCurrentUser() async {
    // AuthService now returns normalized user data (already extracted from nested structure)
    return await _authService.getCurrentUser();
  }

  Future<Map<String, dynamic>> updateProfile({
    String? bio,
    String? phoneNumber,
    String? location,
    String? currentRole,
    String? company,
    String? profession,
    List<String>? skills,
    bool? openToMentor,
    String? profileImageBase64,
    String? coverImageBase64,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      
      if (bio != null) body['bio'] = bio;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
      if (location != null) body['location'] = location;
      if (currentRole != null) body['currentRole'] = currentRole;
      if (company != null) body['company'] = company;
      if (profession != null) body['profession'] = profession;
      if (skills != null) body['skills'] = skills;
      if (openToMentor != null) body['openToMentor'] = openToMentor;
      if (profileImageBase64 != null) body['profileImage'] = profileImageBase64;
      if (coverImageBase64 != null) body['coverImage'] = coverImageBase64;

      // Get user ID from stored user data
      final currentUser = await getCurrentUser();
      final userId = currentUser['id'];
      
      if (userId == null || userId.toString().isEmpty) {
        throw Exception('User ID not found. Please login again.');
      }
      
      debugPrint('Updating profile for user ID: $userId');

      final response = await _authService.authenticatedRequest(
        'PATCH',
        '/api/users/$userId/profile',
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Profile updated successfully');
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await updateProfile(
        profileImageBase64: 'data:image/jpeg;base64,$base64Image',
      );

      return response['profileImage'];
    } catch (e) {
      debugPrint('Upload profile image error: $e');
      rethrow;
    }
  }

  Future<String?> uploadCoverImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await updateProfile(
        coverImageBase64: 'data:image/jpeg;base64,$base64Image',
      );

      return response['coverImage'];
    } catch (e) {
      debugPrint('Upload cover image error: $e');
      rethrow;
    }
  }
}
