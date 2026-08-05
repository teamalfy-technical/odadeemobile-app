import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Debug-only API logging that redacts credentials and personal data.
class ApiLogger {
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'access_token',
    'accesstoken',
    'refresh_token',
    'refreshtoken',
    'token',
    'password',
    'newpassword',
    'currentpassword',
    'email',
    'phonenumber',
    'pushnotificationtoken',
  };

  static void logRequest(String url, {Object? headers, Object? body}) {
    if (!kDebugMode) return;
    debugPrint(
      '[API] ${_safeUrl(url)} request '
      'headers=${_encode(_redact(headers))} body=${_encode(_redact(body))}',
    );
  }

  static void logResponse(int statusCode, {Object? body}) {
    if (!kDebugMode) return;
    debugPrint(
      '[API] response status=$statusCode body=${_encode(_redact(body))}',
    );
  }

  static String _safeUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return value.split('?').first;
    final segments = [...uri.pathSegments];
    for (var index = 0; index < segments.length - 1; index++) {
      if (segments[index] == 'validate' &&
          index > 0 &&
          segments[index - 1] == 'magic-link') {
        segments[index + 1] = '[REDACTED]';
      }
    }
    return uri
        .replace(
          pathSegments: segments,
          query: null,
          fragment: null,
        )
        .toString();
  }

  static Object? _redact(Object? value) {
    if (value is String) {
      try {
        return _redact(jsonDecode(value));
      } catch (_) {
        return value.length > 500 ? '${value.substring(0, 500)}…' : value;
      }
    }
    if (value is Map) {
      return value.map((key, item) {
        final normalizedKey = key.toString().toLowerCase().replaceAll('_', '');
        final isSensitive = _sensitiveKeys.any(
          (candidate) =>
              candidate.replaceAll('_', '') == normalizedKey ||
              normalizedKey.contains(candidate.replaceAll('_', '')),
        );
        return MapEntry(
          key.toString(),
          isSensitive ? '[REDACTED]' : _redact(item),
        );
      });
    }
    if (value is Iterable) return value.map(_redact).toList();
    return value;
  }

  static String _encode(Object? value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }
}
