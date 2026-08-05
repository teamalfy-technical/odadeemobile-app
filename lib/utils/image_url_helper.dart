import 'package:odadee/config/api_config.dart';

class ImageUrlHelper {
  static const String imageEndpoint = '/api/images';

  static String? normalizeImageUrl(String? url) {
    final imagePath = url?.trim();
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    if (imagePath.startsWith('data:')) {
      return imagePath;
    }

    final parsedUrl = Uri.tryParse(imagePath);
    if (parsedUrl?.host == 'dashboard.odadee.net') {
      return null;
    }

    if (parsedUrl?.host == 'storage.googleapis.com') {
      final storagePath = parsedUrl!.path.replaceFirst(RegExp(r'^/+'), '');
      return storagePath.isEmpty
          ? null
          : '${ApiConfig.baseUrl}$imageEndpoint/$storagePath';
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    if (imagePath.startsWith('/api/images/')) {
      return '${ApiConfig.baseUrl}$imagePath';
    }

    if (imagePath.startsWith('/')) {
      return '${ApiConfig.baseUrl}$imagePath';
    }

    if (imagePath.startsWith('api/images/')) {
      return '${ApiConfig.baseUrl}/$imagePath';
    }

    final normalizedPath = imagePath.replaceFirst(RegExp(r'^/+'), '');
    return '${ApiConfig.baseUrl}$imageEndpoint/$normalizedPath';
  }
}
