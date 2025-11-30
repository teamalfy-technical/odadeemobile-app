import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:odadee/services/discussion_service.dart';
import 'package:odadee/components/authenticated_image.dart';
import 'package:odadee/utils/image_url_helper.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/theme_service.dart';
import 'package:intl/intl.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({Key? key}) : super(key: key);

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  final DiscussionService _discussionService = DiscussionService();
  final TextEditingController _titleController = TextEditingController();
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
    {'value': 'career', 'label': 'Career', 'icon': Icons.work_outline},
    {'value': 'networking', 'label': 'Networking', 'icon': Icons.connect_without_contact},
    {'value': 'announcements', 'label': 'Announcements', 'icon': Icons.campaign},
  ];

  @override
  void initState() {
    super.initState();
    print('=== DISCUSSIONS SCREEN: INIT STATE ===');
    _loadPosts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    print('=== DISCUSSIONS SCREEN: LOADING POSTS ===');
    setState(() => _isLoading = true);
    try {
      final posts = await _discussionService.getPosts(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );
      print('=== DISCUSSIONS SCREEN: Loaded ${posts.length} posts ===');
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
        print('=== DISCUSSIONS SCREEN: UI updated, isLoading=$_isLoading ===');
      }
    } catch (e) {
      print('=== DISCUSSIONS SCREEN ERROR: $e ===');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load discussions: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  Future<void> _createPost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title for your post'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_postController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter content for your post'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isPosting = true);
    try {
      final newPost = await _discussionService.createPost(
        title: _titleController.text.trim(),
        content: _postController.text.trim(),
        category: _newPostCategory,
      );
      
      setState(() {
        _posts.insert(0, newPost);
        _titleController.clear();
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
          content: Text('Failed to create post: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreatePostSheet() {
    final cardColor = AppColors.cardColor(context);
    final surfaceColor = AppColors.surfaceColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    final borderColor = AppColors.borderColor(context);
    
    _newPostCategory = 'general';
    _titleController.clear();
    _postController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
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
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: subtitleColor),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                Text(
                  'Category',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButton<String>(
                    value: _newPostCategory,
                    isExpanded: true,
                    dropdownColor: cardColor,
                    underline: SizedBox(),
                    style: TextStyle(color: textColor),
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
                  'Title',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter a title for your post...',
                    hintStyle: TextStyle(color: mutedColor),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: odaPrimary),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                
                Text(
                  'Content',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _postController,
                  maxLines: 4,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts with the community...',
                    hintStyle: TextStyle(color: mutedColor),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: odaPrimary),
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
                      backgroundColor: odaPrimary,
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
    final cardColor = AppColors.cardColor(context);
    final surfaceColor = AppColors.surfaceColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    final borderColor = AppColors.borderColor(context);
    
    final TextEditingController commentController = TextEditingController();
    List<DiscussionComment> comments = [];
    bool loadingComments = true;
    bool posting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
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
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments (${post.commentsCount})',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: loadingComments
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                          ),
                        )
                      : comments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      size: 48, color: mutedColor),
                                  SizedBox(height: 16),
                                  Text(
                                    'No comments yet',
                                    style: TextStyle(color: subtitleColor),
                                  ),
                                  Text(
                                    'Be the first to comment!',
                                    style: TextStyle(
                                        color: mutedColor, fontSize: 12),
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
                                return _buildCommentCard(comment, surfaceColor, textColor, subtitleColor, mutedColor);
                              },
                            ),
                ),
                
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(
                      top: BorderSide(color: borderColor),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(color: mutedColor),
                              filled: true,
                              fillColor: cardColor,
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
                            color: odaPrimary,
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
                                        SnackBar(
                                          content: Text('${e.toString().replaceAll('Exception: ', '')}'),
                                          backgroundColor: Colors.red,
                                        ),
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

  Widget _buildCommentCard(DiscussionComment comment, Color surfaceColor, Color textColor, Color subtitleColor, Color mutedColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(comment.author?.profileImage, comment.author?.fullName ?? 'User', 32),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.author?.fullName ?? 'Anonymous',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(color: mutedColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            comment.content,
            style: TextStyle(color: subtitleColor, fontSize: 13),
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
        color: odaPrimary,
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
    final cardColor = AppColors.cardColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    final borderColor = AppColors.borderColor(context);
    
    final category = _categories.firstWhere(
      (c) => c['value'] == post.category,
      orElse: () => {'label': post.category, 'icon': Icons.chat},
    );

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(post.author?.profileImage, post.author?.fullName ?? 'User', 44),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author?.fullName ?? 'Anonymous',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _formatTimeAgo(post.createdAt),
                          style: TextStyle(color: mutedColor, fontSize: 12),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: odaPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                size: 12,
                                color: odaPrimary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                category['label'] as String,
                                style: TextStyle(
                                  color: odaPrimary,
                                  fontSize: 11,
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
          SizedBox(height: 12),
          
          if (post.title.isNotEmpty) ...[
            Text(
              post.title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
          ],
          
          Text(
            post.content,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              InkWell(
                onTap: () => _showCommentsSheet(post, index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: mutedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 18, color: subtitleColor),
                      SizedBox(width: 6),
                      Text(
                        '${post.commentsCount}',
                        style: TextStyle(color: subtitleColor, fontSize: 13),
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
    print('=== DISCUSSIONS SCREEN: BUILD METHOD v2 ===');
    final backgroundColor = AppColors.isDark(context) ? Color(0xFF0f172a) : Colors.grey[100];
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final cardColor = AppColors.cardColor(context);
    final borderColor = AppColors.borderColor(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Discussions',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: subtitleColor),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            color: cardColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['value'];
                
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat['value'] as String);
                        _loadPosts();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? odaPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? odaPrimary : borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 16,
                              color: isSelected ? Colors.white : subtitleColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              cat['label'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : subtitleColor,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                    ),
                  )
                : _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 64, color: subtitleColor),
                            SizedBox(height: 16),
                            Text(
                              'No discussions yet',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start a conversation with the community!',
                              style: TextStyle(color: subtitleColor),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPosts,
                        color: odaPrimary,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) => _buildPostCard(_posts[index], index),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostSheet,
        backgroundColor: odaPrimary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
