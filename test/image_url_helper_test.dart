import 'package:flutter_test/flutter_test.dart';
import 'package:odadee/utils/image_url_helper.dart';

void main() {
  group('ImageUrlHelper.normalizeImageUrl', () {
    test('normalizes current object-storage paths', () {
      expect(
        ImageUrlHelper.normalizeImageUrl('uploads/image-id'),
        'https://odadee.net/api/images/uploads/image-id',
      );
      expect(
        ImageUrlHelper.normalizeImageUrl('public/uploads/image-id'),
        'https://odadee.net/api/images/public/uploads/image-id',
      );
      expect(
        ImageUrlHelper.normalizeImageUrl('/api/images/uploads/image-id'),
        'https://odadee.net/api/images/uploads/image-id',
      );
    });

    test('routes legacy Google Storage URLs through the image endpoint', () {
      expect(
        ImageUrlHelper.normalizeImageUrl(
          'https://storage.googleapis.com/bucket/profile-assets/uploads/image-id?legacy=1',
        ),
        'https://odadee.net/api/images/bucket/profile-assets/uploads/image-id',
      );
    });

    test('keeps valid external and root-relative URLs displayable', () {
      expect(
        ImageUrlHelper.normalizeImageUrl('https://example.com/image.jpg'),
        'https://example.com/image.jpg',
      );
      expect(
        ImageUrlHelper.normalizeImageUrl('/objects/image-id'),
        'https://odadee.net/objects/image-id',
      );
    });

    test('suppresses retired dashboard URLs', () {
      expect(
        ImageUrlHelper.normalizeImageUrl(
          'https://dashboard.odadee.net/uploads/old-image.jpg',
        ),
        isNull,
      );
    });
  });
}
