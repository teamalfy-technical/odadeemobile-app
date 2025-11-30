import 'package:flutter/material.dart';
import 'package:odadee/services/discussion_service.dart';
import 'package:odadee/components/authenticated_image.dart';
import 'package:odadee/utils/image_url_helper.dart';
import 'package:intl/intl.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({Key? key}) : super(key: key);

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  final DiscussionService _discussionService = DiscussionService();
  final TextEditingController _postController = TextEditingController();
  
  List<DiscussionPost> _posts = [];
  bool _isLoading = true;
  bool _isPosting = false;
  String _selectedCategory = 'all';
  String _newPostCategory = 'general';
  
  final List<Map<String, dynamic>> _categories = [
    {'value': 'all', 'label': 'All Posts', 'icon': Icons.dashboard},
    {'value': 'general', 'label': 'General', 'icon': Icons.chat_bubble_outline},
    {'value': 'mentorship', 'label': 'Mentorship', 'icon': Icons.people},
    {'value': 'jobs', 'label': 'Jobs & Careers', 'icon': Icons.work_outline},
    {'value': 'networking', 'label': 'Networking', 'icon': Icons.connect_without_contact},
    {'value': 'announcements', 'label': 'Announcements', 'icon': Icons.campaign},
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _discussionService.getPosts(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load discussions: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;
    
    setState(() => _isPosting = true);
    try {
      final newPost = await _discussionService.createPost(
        content: _postController.text.trim(),
        category: _newPostCategory,
      );
      
      setState(() {
        _posts.insert(0, newPost);
        _postController.clear();
        _isPosting = false;
      });
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Color(0xFF10b981),
        ),
      );
    } catch (e) {
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create post: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleLike(DiscussionPost post, int index) async {
    final wasLiked = post.isLiked;
    
    setState(() {
      _posts[index] = post.copyWith(
        isLiked: !wasLiked,
        likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
    });
    
    bool success;
    if (wasLiked) {
      success = await _discussionService.unlikePost(post.id);
    } else {
      success = await _discussionService.likePost(post.id);
    }
    
    if (!success) {
      setState(() {
        _posts[index] = post;
      });
    }
  }

  void _showCreatePostSheet() {
    _newPostCategory = 'general';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Color(0xFF94a3b8)),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                Text(
                  'Category',
                  style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFF0f172a),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF334155)),
                  ),
                  child: DropdownButton<String>(
                    value: _newPostCategory,
                    isExpanded: true,
                    dropdownColor: Color(0xFF1e293b),
                    underline: SizedBox(),
                    style: TextStyle(color: Colors.white),
                    items: _categories
                        .where((c) => c['value'] != 'all')
                        .map((c) => DropdownMenuItem(
                              value: c['value'] as String,
                              child: Text(c['label'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => _newPostCategory = value!);
                    },
                  ),
                ),
                SizedBox(height: 16),
                
                Text(
                  'What\'s on your mind?',
                  style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _postController,
                  maxLines: 4,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts with the community...',
                    hintStyle: TextStyle(color: Color(0xFF64748b)),
                    filled: true,
                    fillColor: Color(0xFF0f172a),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF334155)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF2563eb)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isPosting ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563eb),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isPosting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Post',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentsSheet(DiscussionPost post, int postIndex) {
    final TextEditingController commentController = TextEditingController();
    List<DiscussionComment> comments = [];
    bool loadingComments = true;
    bool posting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          if (loadingComments) {
            _discussionService.getComments(post.id).then((loadedComments) {
              setModalState(() {
                comments = loadedComments;
                loadingComments = false;
              });
            }).catchError((e) {
              setModalState(() => loadingComments = false);
            });
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF334155)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments (${post.commentsCount})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Color(0xFF94a3b8)),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: loadingComments
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563eb)),
                          ),
                        )
                      : comments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      size: 48, color: Color(0xFF64748b)),
                                  SizedBox(height: 16),
                                  Text(
                                    'No comments yet',
                                    style: TextStyle(color: Color(0xFF94a3b8)),
                                  ),
                                  Text(
                                    'Be the first to comment!',
                                    style: TextStyle(
                                        color: Color(0xFF64748b), fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.all(16),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return _buildCommentCard(comment);
                              },
                            ),
                ),
                
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0f172a),
                    border: Border(
                      top: BorderSide(color: Color(0xFF334155)),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(color: Color(0xFF64748b)),
                              filled: true,
                              fillColor: Color(0xFF1e293b),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF2563eb),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: posting
                                ? null
                                : () async {
                                    if (commentController.text.trim().isEmpty) return;
                                    
                                    setModalState(() => posting = true);
                                    try {
                                      final newComment = await _discussionService.addComment(
                                        postId: post.id,
                                        content: commentController.text.trim(),
                                      );
                                      setModalState(() {
                                        comments.add(newComment);
                                        posting = false;
                                      });
                                      commentController.clear();
                                      
                                      setState(() {
                                        _posts[postIndex] = post.copyWith(
                                          commentsCount: post.commentsCount + 1,
                                        );
                                      });
                                    } catch (e) {
                                      setModalState(() => posting = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to add comment')),
                                      );
                                    }
                                  },
                            icon: posting
                                ? SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(Icons.send, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentCard(DiscussionComment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF0f172a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(comment.user?.profileImage, comment.user?.fullName ?? 'User', 32),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user?.fullName ?? 'Anonymous',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(color: Color(0xFF64748b), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            comment.content,
            style: TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildAvatar(String? imageUrl, String name, double size) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final normalizedUrl = ImageUrlHelper.normalizeImageUrl(imageUrl);
      if (normalizedUrl != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: AuthenticatedImage(
            imageUrl: normalizedUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: _buildInitialsAvatar(name, size),
            errorWidget: _buildInitialsAvatar(name, size),
          ),
        );
      }
    }
    return _buildInitialsAvatar(name, size);
  }

  Widget _buildInitialsAvatar(String name, double size) {
    final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0xFF2563eb),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(DiscussionPost post, int index) {
    final category = _categories.firstWhere(
      (c) => c['value'] == post.category,
      orElse: () => {'label': post.category, 'icon': Icons.chat},
    );

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(post.user?.profileImage, post.user?.fullName ?? 'User', 44),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user?.fullName ?? 'Anonymous',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _formatTimeAgo(post.createdAt),
                          style: TextStyle(color: Color(0xFF64748b), fontSize: 12),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFF2563eb).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                size: 12,
                                color: Color(0xFF2563eb),
                              ),
                              SizedBox(width: 4),
                              Text(
                                category['label'] as String,
                                style: TextStyle(
                                  color: Color(0xFF2563eb),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Text(
            post.content,
            style: TextStyle(
              color: Color(0xFF94a3b8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 16),
          
          Row(
            children: [
              InkWell(
                onTap: () => _toggleLike(post, index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: post.isLiked
                        ? Color(0xFF2563eb).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: post.isLiked ? Color(0xFF2563eb) : Color(0xFF334155),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: post.isLiked ? Color(0xFF2563eb) : Color(0xFF64748b),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(
                          color: post.isLiked ? Color(0xFF2563eb) : Color(0xFF64748b),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              InkWell(
                onTap: () => _showCommentsSheet(post, index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: Color(0xFF64748b),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${post.commentsCount}',
                        style: TextStyle(color: Color(0xFF64748b), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Discussions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['value'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category['value'] as String);
                    _loadPosts();
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF2563eb) : Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Color(0xFF2563eb) : Color(0xFF334155),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : Color(0xFF94a3b8),
                        ),
                        SizedBox(width: 6),
                        Text(
                          category['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Color(0xFF94a3b8),
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563eb)),
                    ),
                  )
                : _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined,
                                size: 64, color: Color(0xFF64748b)),
                            SizedBox(height: 16),
                            Text(
                              'No discussions yet',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start a conversation with the community!',
                              style: TextStyle(color: Color(0xFF94a3b8)),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _showCreatePostSheet,
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text('Create Post',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2563eb),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPosts,
                        color: Color(0xFF2563eb),
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            return _buildPostCard(_posts[index], index);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostSheet,
        backgroundColor: Color(0xFF2563eb),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
