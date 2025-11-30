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
      
      print('=== DISCUSSION SERVICE: GET REQUEST ===');
      print('Endpoint: $endpoint');
      
      final response = await _authService.authenticatedRequest('GET', endpoint);

      print('=== DISCUSSION SERVICE: GET RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postsJson = data['discussions'] ?? data['posts'] ?? [];
        print('=== DISCUSSION SERVICE: Parsing ${postsJson.length} discussions ===');
        
        final List<DiscussionPost> posts = [];
        for (int i = 0; i < postsJson.length; i++) {
          try {
            final post = DiscussionPost.fromJson(postsJson[i] as Map<String, dynamic>);
            posts.add(post);
          } catch (e) {
            print('=== DISCUSSION SERVICE: Error parsing at index $i: $e ===');
            print('Raw data: ${postsJson[i]}');
          }
        }
        print('=== DISCUSSION SERVICE: Successfully parsed ${posts.length} discussions ===');
        return posts;
      }
      
      String errorMessage = 'Failed to load discussions';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to load discussions (${response.statusCode})';
      } catch (_) {}
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error fetching discussions: $e');
      rethrow;
    }
  }

  Future<DiscussionPost> getPost(String id) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/discussions/$id',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DiscussionPost.fromJson(data['post'] ?? data['discussion'] ?? data);
      }
      throw Exception('Discussion not found');
    } catch (e) {
      debugPrint('Error fetching discussion: $e');
      rethrow;
    }
  }

  Future<DiscussionPost> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    try {
      debugPrint('=== CREATE DISCUSSION REQUEST ===');
      debugPrint('Title: $title');
      debugPrint('Content: $content');
      debugPrint('Category: $category');
      
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/discussions',
        body: {
          'title': title,
          'content': content,
          'category': category,
        },
      );

      debugPrint('=== CREATE DISCUSSION RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('==================================');

      // API returns 201 for created
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DiscussionPost.fromJson(data['post'] ?? data['discussion'] ?? data);
      }
      
      String errorMessage = 'Failed to create post';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to create post (${response.statusCode})';
      } catch (_) {}
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  Future<DiscussionPost> updatePost({
    required String postId,
    String? title,
    String? content,
    String? category,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (content != null) body['content'] = content;
      if (category != null) body['category'] = category;

      final response = await _authService.authenticatedRequest(
        'PATCH',
        '/api/discussions/$postId',
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DiscussionPost.fromJson(data['post'] ?? data['discussion'] ?? data);
      }
      
      String errorMessage = 'Failed to update post';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to update post (${response.statusCode})';
      } catch (_) {}
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'DELETE',
        '/api/discussions/$postId',
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Failed to delete post';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to delete post (${response.statusCode})';
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  Future<List<DiscussionComment>> getComments(String postId) async {
    try {
      debugPrint('=== GET COMMENTS REQUEST ===');
      debugPrint('Post ID: $postId');
      
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/discussions/$postId/comments',
      );

      debugPrint('=== GET COMMENTS RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
      debugPrint('=============================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> commentsJson = data['comments'] ?? [];
        return commentsJson.map((c) => DiscussionComment.fromJson(c)).toList();
      }
      
      String errorMessage = 'Failed to load comments';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to load comments (${response.statusCode})';
      } catch (_) {}
      
      throw Exception(errorMessage);
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
      debugPrint('=== ADD COMMENT REQUEST ===');
      debugPrint('Post ID: $postId');
      debugPrint('Content: $content');
      
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/discussions/$postId/comments',
        body: {'content': content},
      );

      debugPrint('=== ADD COMMENT RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('============================');

      // API returns 201 for created
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DiscussionComment.fromJson(data['comment'] ?? data);
      }
      
      String errorMessage = 'Failed to add comment';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to add comment (${response.statusCode})';
        
        // Handle specific error for unverified members
        if (response.statusCode == 403) {
          errorMessage = 'Only verified members can post comments';
        }
      } catch (_) {}
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await _authService.authenticatedRequest(
        'DELETE',
        '/api/discussions/$postId/comments/$commentId',
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Failed to delete comment';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to delete comment (${response.statusCode})';
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      rethrow;
    }
  }
}

class DiscussionPost {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Author? author;

  DiscussionPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory DiscussionPost.fromJson(Map<String, dynamic> json) {
    // Calculate comment count from various possible fields
    int commentCount = 0;
    
    // Check various field names for comment count
    if (json['commentsCount'] != null) {
      commentCount = json['commentsCount'] is int ? json['commentsCount'] : int.tryParse(json['commentsCount'].toString()) ?? 0;
    } else if (json['commentCount'] != null) {
      commentCount = json['commentCount'] is int ? json['commentCount'] : int.tryParse(json['commentCount'].toString()) ?? 0;
    } else if (json['_count'] != null && json['_count']['comments'] != null) {
      commentCount = json['_count']['comments'] is int ? json['_count']['comments'] : int.tryParse(json['_count']['comments'].toString()) ?? 0;
    } else if (json['comments'] != null && json['comments'] is List) {
      commentCount = (json['comments'] as List).length;
    } else if (json['numComments'] != null) {
      commentCount = json['numComments'] is int ? json['numComments'] : int.tryParse(json['numComments'].toString()) ?? 0;
    }
    
    // Parse author - check both 'author' and 'user' fields
    Author? author;
    if (json['author'] != null) {
      author = Author.fromJson(json['author']);
    } else if (json['user'] != null) {
      author = Author.fromJson(json['user']);
    }
    
    // Debug log to see what fields are available
    print('=== DISCUSSION POST PARSING ===');
    print('ID: ${json['id']}');
    print('Title: ${json['title']}');
    print('author field: ${json['author']}');
    print('user field: ${json['user']}');
    print('Parsed author: ${author?.fullName ?? "null"}');
    print('commentsCount field: ${json['commentsCount']}');
    print('commentCount field: ${json['commentCount']}');
    print('_count field: ${json['_count']}');
    print('comments field: ${json['comments'] is List ? 'List with ${(json['comments'] as List).length} items' : json['comments']}');
    print('Calculated commentCount: $commentCount');
    print('===============================');
    
    return DiscussionPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'general',
      commentsCount: commentCount,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      author: author,
    );
  }

  DiscussionPost copyWith({
    int? commentsCount,
  }) {
    return DiscussionPost(
      id: id,
      userId: userId,
      title: title,
      content: content,
      category: category,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      author: author,
    );
  }
}

class Author {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;

  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? '',
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
  final Author? author;

  DiscussionComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.author,
  });

  factory DiscussionComment.fromJson(Map<String, dynamic> json) {
    return DiscussionComment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? json['discussionId'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
    );
  }
}
