class ImageUrlHelper {
  static const String baseUrl = 'https://odadee.net';
  static const String imageEndpoint = '/api/images';

  static String? normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    String normalizedUrl = url;
    if (normalizedUrl.startsWith('/')) {
      normalizedUrl = normalizedUrl.substring(1);
    }

    if (normalizedUrl.startsWith('uploads/')) {
      return '$baseUrl$imageEndpoint/$normalizedUrl';
    } else {
      return '$baseUrl$imageEndpoint/uploads/$normalizedUrl';
    }
  }
}
