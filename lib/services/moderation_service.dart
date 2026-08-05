import 'dart:convert';

import 'package:profanity_filter/profanity_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

/// Moderation primitives shared by profiles, discussions, and comments.
///
/// Blocking is persisted locally first so hidden content stays hidden even
/// while offline. The API call is best-effort and lets the server synchronize
/// the block across devices when the moderation endpoints are available.
class ModerationService {
  static const _blockedUserIdsKey = 'moderation_blocked_user_ids';
  static const _blockedAuthorNamesKey = 'moderation_blocked_author_names';
  static const _pendingReportsKey = 'moderation_pending_reports';

  final AuthService _authService;
  final ProfanityFilter _profanityFilter;

  ModerationService({AuthService? authService})
      : _authService = authService ?? AuthService(),
        _profanityFilter = ProfanityFilter();

  bool containsObjectionableContent(String value) {
    final normalized = value.trim();
    return normalized.isNotEmpty && _profanityFilter.hasProfanity(normalized);
  }

  Future<Set<String>> getBlockedUserIds() async {
    final preferences = await SharedPreferences.getInstance();
    final storageKey = await _userScopedKey(_blockedUserIdsKey);
    final blockedIds =
        preferences.getStringList(storageKey)?.toSet() ?? <String>{};
    final serverBlocks = await _fetchServerBlocks();
    blockedIds.addAll(
      serverBlocks
          .map((block) => block['blockedUserId']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty),
    );
    await preferences.setStringList(storageKey, blockedIds.toList()..sort());
    return blockedIds;
  }

  Future<Set<String>> getBlockedAuthorNames() async {
    final preferences = await SharedPreferences.getInstance();
    final storageKey = await _userScopedKey(_blockedAuthorNamesKey);
    final blockedNames =
        preferences.getStringList(storageKey)?.toSet() ?? <String>{};
    final serverBlocks = await _fetchServerBlocks();
    blockedNames.addAll(
      serverBlocks
          .map((block) => block['blockedAuthorName']?.toString())
          .whereType<String>()
          .where((name) => name.isNotEmpty),
    );
    await preferences.setStringList(
      storageKey,
      blockedNames.toList()..sort(),
    );
    return blockedNames;
  }

  Future<void> blockUser({
    required String blockedUserId,
    String? lastSeenContentId,
    String? lastSeenContentType,
  }) async {
    final id = blockedUserId.trim();
    if (id.isEmpty) throw ArgumentError('A user ID is required');

    final preferences = await SharedPreferences.getInstance();
    final storageKey = await _userScopedKey(_blockedUserIdsKey);
    final blockedIds =
        preferences.getStringList(storageKey)?.toSet() ?? <String>{};
    blockedIds.add(id);
    await preferences.setStringList(
      storageKey,
      blockedIds.toList()..sort(),
    );

    await _trySyncBlock({
      'blockedUserId': id,
      if (lastSeenContentId != null) 'lastSeenContentId': lastSeenContentId,
      if (lastSeenContentType != null)
        'lastSeenContentType': lastSeenContentType,
    });
  }

  Future<void> blockAuthorName({
    required String authorName,
    String? lastSeenContentId,
    String? lastSeenContentType,
  }) async {
    final name = authorName.trim();
    if (name.isEmpty) throw ArgumentError('An author name is required');

    final preferences = await SharedPreferences.getInstance();
    final storageKey = await _userScopedKey(_blockedAuthorNamesKey);
    final blockedNames =
        preferences.getStringList(storageKey)?.toSet() ?? <String>{};
    blockedNames.add(name);
    await preferences.setStringList(
      storageKey,
      blockedNames.toList()..sort(),
    );

    await _trySyncBlock({
      'blockedAuthorName': name,
      if (lastSeenContentId != null) 'lastSeenContentId': lastSeenContentId,
      if (lastSeenContentType != null)
        'lastSeenContentType': lastSeenContentType,
    });
  }

  Future<void> reportContent({
    required String contentType,
    required String contentId,
    required String reason,
    String? details,
    String? reportedUserId,
    String? contentSnapshot,
  }) async {
    await _flushPendingReports();
    final report = <String, dynamic>{
      'contentType': contentType,
      'contentId': contentId,
      'reason': reason,
      if (details?.trim().isNotEmpty ?? false) 'details': details!.trim(),
      if (_isUuid(reportedUserId?.trim()))
        'reportedUserId': reportedUserId!.trim(),
      if (contentSnapshot?.trim().isNotEmpty ?? false)
        'contentSnapshot': contentSnapshot!.trim(),
      'reportedAt': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/moderation/reports',
        body: report,
      );
      if (response.statusCode == 200 || response.statusCode == 201) return;
    } catch (_) {
      // Queue below so a temporary API outage does not discard the report.
    }

    final preferences = await SharedPreferences.getInstance();
    final storageKey = await _userScopedKey(_pendingReportsKey);
    final pending = preferences.getStringList(storageKey) ?? <String>[];
    pending.add(jsonEncode(report));
    await preferences.setStringList(storageKey, pending);
  }

  Future<void> _trySyncBlock(Map<String, dynamic> body) async {
    try {
      await _authService.authenticatedRequest(
        'POST',
        '/api/moderation/blocks',
        body: body,
      );
    } catch (_) {
      // Local persistence already enforces the user's block immediately.
    }
  }

  Future<List<Map<String, dynamic>>> _fetchServerBlocks() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/moderation/blocks',
      );
      if (response.statusCode != 200) return const [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final blocks = data['blocks'] as List<dynamic>? ?? const [];
      return blocks.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _flushPendingReports() async {
    final preferences = await SharedPreferences.getInstance();
    final storageKey = await _userScopedKey(_pendingReportsKey);
    final pending = preferences.getStringList(storageKey) ?? const <String>[];
    if (pending.isEmpty) return;

    final remaining = <String>[];
    for (final encoded in pending) {
      try {
        final report = jsonDecode(encoded) as Map<String, dynamic>;
        final response = await _authService.authenticatedRequest(
          'POST',
          '/api/moderation/reports',
          body: report,
        );
        if (response.statusCode != 200 && response.statusCode != 201) {
          remaining.add(encoded);
        }
      } catch (_) {
        remaining.add(encoded);
      }
    }
    await preferences.setStringList(storageKey, remaining);
  }

  Future<String> _userScopedKey(String baseKey) async {
    final userId = await _authService.storage.read(key: 'user_id');
    return '${baseKey}_${userId?.isNotEmpty == true ? userId : 'anonymous'}';
  }

  bool _isUuid(String? value) =>
      value != null &&
      RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      ).hasMatch(value);
}
