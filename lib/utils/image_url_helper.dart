class ImageUrlHelper {
  static const String baseUrl = 'https://odadee.net';
  static const String imageEndpoint = '/api/images';

  static String? normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    // Already a full URL - return as-is
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    String normalizedUrl = url;
    if (normalizedUrl.startsWith('/')) {
      normalizedUrl = normalizedUrl.substring(1);
    }

    // Already contains the api/images path - just add base URL
    if (normalizedUrl.startsWith('api/images/') || normalizedUrl.contains('/api/images/')) {
      return '$baseUrl/$normalizedUrl';
    }

    // Starts with uploads/ - add the image endpoint
    if (normalizedUrl.startsWith('uploads/')) {
      return '$baseUrl$imageEndpoint/$normalizedUrl';
    }
    
    // Plain filename or other path - add full prefix
    return '$baseUrl$imageEndpoint/uploads/$normalizedUrl';
  }
}
