import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/image_url_helper.dart';

class EventImageWidget extends StatefulWidget {
  final String? imageUrl;
  final String placeholderImage;
  final double height;
  final double width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const EventImageWidget({
    Key? key,
    required this.imageUrl,
    this.placeholderImage = 'assets/images/event_placeholder.png',
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<EventImageWidget> createState() => _EventImageWidgetState();
}

class _EventImageWidgetState extends State<EventImageWidget> {
  late Future<Map<String, String>> _headersFuture;

  @override
  void initState() {
    super.initState();
    _headersFuture = _getAuthHeaders();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final authService = AuthService();
    final token = await authService.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    final String? normalizedUrl = ImageUrlHelper.normalizeImageUrl(widget.imageUrl);
    if (normalizedUrl == null) {
      return _buildPlaceholder();
    }

    return FutureBuilder<Map<String, String>>(
      future: _headersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        }

        if (snapshot.hasError) {
          return _buildPlaceholder();
        }

        final headers = snapshot.data ?? {};

        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: Image(
              image: NetworkImage(
                normalizedUrl,
                headers: headers,
              ),
              fit: widget.fit,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Image.asset(
          widget.placeholderImage,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey[600],
                size: 48,
              ),
            );
          },
        ),
      ),
    );
  }
}
