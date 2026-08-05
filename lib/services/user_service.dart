import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
    String? profileImage,
    String? coverImage,
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
      if (profileImage != null) body['profileImage'] = profileImage;
      if (coverImage != null) body['coverImage'] = coverImage;

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
        return Map<String, dynamic>.from(data['user'] ?? data);
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
      final objectPath = await _uploadPublicImage(imageFile);
      await updateProfile(profileImage: objectPath);
      return objectPath;
    } catch (e) {
      debugPrint('Upload profile image error: $e');
      rethrow;
    }
  }

  Future<String?> uploadCoverImage(XFile imageFile) async {
    try {
      final objectPath = await _uploadPublicImage(imageFile);
      await updateProfile(coverImage: objectPath);
      return objectPath;
    } catch (e) {
      debugPrint('Upload cover image error: $e');
      rethrow;
    }
  }

  Future<String> _uploadPublicImage(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('The selected image is empty.');
    }
    if (bytes.length > 10 * 1024 * 1024) {
      throw Exception('The selected image must be smaller than 10MB.');
    }

    final preparationResponse = await _authService.authenticatedRequest(
      'POST',
      '/api/objects/upload-public',
    );
    if (preparationResponse.statusCode != 200) {
      throw Exception(_errorMessage(
        preparationResponse.body,
        'Failed to prepare image upload',
      ));
    }

    final preparation = jsonDecode(preparationResponse.body);
    final uploadUrl = preparation['uploadURL']?.toString();
    final publicUrl = preparation['publicURL']?.toString();
    if (uploadUrl == null || publicUrl == null) {
      throw Exception('The server returned an invalid image upload response.');
    }

    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': _contentTypeFor(imageFile)},
      body: bytes,
    );
    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      throw Exception('Failed to upload the selected image.');
    }

    final aclResponse = await _authService.authenticatedRequest(
      'POST',
      '/api/objects/set-public-acl',
      body: {'publicURL': publicUrl},
    );
    if (aclResponse.statusCode != 200) {
      throw Exception(_errorMessage(
        aclResponse.body,
        'Failed to make the uploaded image available',
      ));
    }

    final aclData = jsonDecode(aclResponse.body);
    final objectPath = aclData['objectPath']?.toString().trim();
    if (objectPath == null || objectPath.isEmpty) {
      throw Exception('The server did not return the uploaded image path.');
    }
    return objectPath;
  }

  String _contentTypeFor(XFile file) {
    final declaredType = file.mimeType;
    if (declaredType != null && declaredType.startsWith('image/')) {
      return declaredType;
    }

    final path = file.path.toLowerCase();
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.gif')) return 'image/gif';
    if (path.endsWith('.webp')) return 'image/webp';
    if (path.endsWith('.heic') || path.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }

  String _errorMessage(String responseBody, String fallback) {
    try {
      final data = jsonDecode(responseBody);
      return data['message']?.toString() ??
          data['error']?.toString() ??
          fallback;
    } catch (_) {
      return fallback;
    }
  }
}
