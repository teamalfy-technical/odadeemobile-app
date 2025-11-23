import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:odadee/Screens/AllUsers/member_detail_page.dart';
import 'package:odadee/Screens/AllUsers/models/all_users_model.dart';
import 'package:odadee/components/authenticated_image.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/config/api_config.dart';
import 'package:odadee/services/auth_service.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<dynamic> members = [];
  bool isLoading = true;
  String? error;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers({String? query}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final authService = AuthService();
      String endpoint = '/api/search/members';
      
      if (query != null && query.isNotEmpty) {
        endpoint += '?query=$query';
      }
      
      final response = await authService.authenticatedRequest('GET', endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          members = data['members'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load members';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching members: $e');
      setState(() {
        error = 'Network error. Please try again.';
        isLoading = false;
      });
    }
  }

  void _performSearch() {
    _fetchMembers(query: searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: odaBackground,
      appBar: AppBar(
        backgroundColor: odaBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: odaSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Members',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: odaCardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: odaSecondary.withOpacity(0.3)),
              ),
              child: TextField(
                controller: searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search, color: odaSecondary),
                    onPressed: _performSearch,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              isLoading = true;
                            });
                            _fetchMembers();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) => _performSearch(),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),

          // Members grid
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(odaSecondary),
                    ),
                  )
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 48),
                            SizedBox(height: 16),
                            Text(
                              error!,
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _fetchMembers(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: odaPrimary,
                              ),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : members.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, color: Colors.white54, size: 64),
                                SizedBox(height: 16),
                                Text(
                                  'No members found',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return _buildMemberCard(member);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(dynamic member) {
    final firstName = member['firstName'] ?? '';
    final lastName = member['lastName'] ?? '';
    final email = member['email'] ?? '';
    final profileImage = member['profileImage'];
    final graduationYear = member['graduationYear']?.toString() ?? '';
    final currentRole = member['currentRole'] ?? '';
    final userId = member['id'];

    String imageUrl = '';
    if (profileImage != null && profileImage.toString().isNotEmpty) {
      if (profileImage.startsWith('http')) {
        imageUrl = profileImage;
      } else {
        imageUrl = '${ApiConfig.baseUrl}/$profileImage';
      }
    }

    return GestureDetector(
      onTap: () {
        final memberData = Data.fromJson(member);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailPage(data: memberData),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: odaCardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: odaSecondary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            // Profile image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: odaSecondary.withOpacity(0.2),
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? AuthenticatedImage(
                        imageUrl: imageUrl,
                        width: 80,
                        height: 80,
                      )
                    : Image.asset(
                        'assets/images/oda_logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(height: 12),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '$firstName $lastName',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            // Graduation year
            if (graduationYear.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: odaSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Class of $graduationYear',
                  style: TextStyle(
                    color: odaSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(height: 8),
            // Role
            if (currentRole.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  currentRole,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Spacer(),
            // View profile button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: odaPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Profile',
                    style: TextStyle(
                      color: odaSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: odaSecondary, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
