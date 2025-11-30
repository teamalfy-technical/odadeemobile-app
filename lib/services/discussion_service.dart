import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:odadee/services/auth_service.dart';

class DiscussionService {
  static final DiscussionService _instance = DiscussionService._internal();
  factory DiscussionService() => _instance;
  DiscussionService._internal();

  final AuthService _authService = AuthService();

  Future<List<DiscussionPost>> getPosts({String? category}) async {
    try {
      String endpoint = '/api/discussions';
      if (category != null && category.isNotEmpty && category != 'all') {
        endpoint += '?category=$category';
      }
      
      final response = await _authService.authenticatedRequest('GET', endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postsJson = data['discussions'] ?? data['posts'] ?? [];
        return postsJson.map((p) => DiscussionPost.fromJson(p)).toList();
      }
      throw Exception('Failed to load discussions');
    } catch (e) {
      debugPrint('Error fetching discussions: $e');
      rethrow;
    }
  }

  Future<DiscussionPost> createPost({
    required String content,
    required String category,
  }) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/discussions',
        body: {
          'content': content,
          'category': category,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DiscussionPost.fromJson(data['post']);
      }
      throw Exception('Failed to create post');
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  Future<List<DiscussionComment>> getComments(String postId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/discussions/$postId/comments',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> commentsJson = data['comments'] ?? [];
        return commentsJson.map((c) => DiscussionComment.fromJson(c)).toList();
      }
      throw Exception('Failed to load comments');
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      rethrow;
    }
  }

  Future<DiscussionComment> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/discussions/$postId/comments',
        body: {'content': content},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DiscussionComment.fromJson(data['comment']);
      }
      throw Exception('Failed to add comment');
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/discussions/$postId/like',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error liking post: $e');
      return false;
    }
  }

  Future<bool> unlikePost(String postId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'DELETE',
        '/api/discussions/$postId/like',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error unliking post: $e');
      return false;
    }
  }
}

class DiscussionPost {
  final String id;
  final String userId;
  final String content;
  final String category;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final PostUser? user;
  final bool isLiked;

  DiscussionPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.category,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    this.user,
    this.isLiked = false,
  });

  factory DiscussionPost.fromJson(Map<String, dynamic> json) {
    return DiscussionPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'general',
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      user: json['user'] != null ? PostUser.fromJson(json['user']) : null,
      isLiked: json['isLiked'] ?? false,
    );
  }

  DiscussionPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return DiscussionPost(
      id: id,
      userId: userId,
      content: content,
      category: category,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      user: user,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class PostUser {
  final String firstName;
  final String lastName;
  final String? profileImage;

  PostUser({
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class DiscussionComment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final PostUser? user;

  DiscussionComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.user,
  });

  factory DiscussionComment.fromJson(Map<String, dynamic> json) {
    return DiscussionComment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      user: json['user'] != null ? PostUser.fromJson(json['user']) : null,
    );
  }
}
