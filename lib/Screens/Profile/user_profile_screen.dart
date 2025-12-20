import 'package:flutter/material.dart';
import 'package:odadee/Screens/Authentication/SignIn/sgin_in_screen.dart';
import 'package:odadee/Screens/Profile/edit_profile_screen.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/components/footer_nav.dart';
import 'package:odadee/components/authenticated_image.dart';
import 'package:odadee/services/user_service.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/utils/image_url_helper.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await _userService.getCurrentUser();
      
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() {
        _errorMessage = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1e293b),
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SignInScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        debugPrint('Logout error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToEdit() async {
    if (_userData == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentUser: _userData!),
      ),
    );

    if (result == true) {
      _loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _errorMessage != null
                          ? _buildErrorState()
                          : _buildProfileContent(),
                ),
              ],
            ),
            FooterNav(activeTab: 'profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                InkWell(
                  onTap: _navigateToEdit,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: odaSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16, color: Color(0xFF0f172a)),
                        SizedBox(width: 4),
                        Text(
                          "Edit",
                          style: TextStyle(
                            color: Color(0xFF0f172a),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: _handleLogout,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Icon(
                      Icons.logout,
                      size: 18,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadUserProfile,
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: odaPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_userData == null) return SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          SizedBox(height: 20),
          _buildBioSection(),
          _buildContactSection(),
          if (_hasProfessionalInfo()) _buildProfessionalSection(),
          if (_hasSkills()) _buildSkillsSection(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final firstName = _userData!['firstName'] ?? '';
    final lastName = _userData!['lastName'] ?? '';
    final profileImagePath = _userData!['profileImage'];
    // Use centralized image URL normalization
    final profileImage = profileImagePath != null && profileImagePath.toString().isNotEmpty
        ? ImageUrlHelper.normalizeImageUrl(profileImagePath.toString())
        : null;
    final graduationYear = _userData!['graduationYear'];

    return Container(
      width: double.infinity,
      color: Color(0xFF1e293b),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: odaSecondary, width: 3),
            ),
            child: ClipOval(
              child: profileImage != null
                  ? AuthenticatedImage(
                      imageUrl: profileImage,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: Color(0xFF1e293b),
                        padding: EdgeInsets.all(30),
                        child: Image.asset(
                          'assets/images/oda_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : Container(
                      color: Color(0xFF1e293b),
                      padding: EdgeInsets.all(30),
                      child: Image.asset(
                        'assets/images/oda_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '$firstName $lastName',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (graduationYear != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: odaSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: odaSecondary),
              ),
              child: Text(
                'Class of $graduationYear',
                style: TextStyle(
                  color: odaSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (_userData!['openToMentor'] == true) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    'Open to Mentor',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    final bio = _userData!['bio']?.toString().trim() ?? '';
    if (bio.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(
                color: odaSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              bio,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                color: odaSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', _userData!['email']),
            if (_userData!['phoneNumber'] != null)
              _buildInfoRow(Icons.phone, 'Phone', _userData!['phoneNumber']),
            if (_userData!['location'] != null)
              _buildInfoRow(Icons.location_on, 'Location', _userData!['location']),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional Information',
              style: TextStyle(
                color: odaSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            if (_userData!['currentRole'] != null)
              _buildInfoRow(Icons.work, 'Role', _userData!['currentRole']),
            if (_userData!['company'] != null)
              _buildInfoRow(Icons.business, 'Company', _userData!['company']),
            if (_userData!['profession'] != null)
              _buildInfoRow(Icons.category, 'Profession', _userData!['profession']),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    final skills = _userData!['skills'];
    if (skills == null || skills is! List || skills.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills',
              style: TextStyle(
                color: odaSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map<Widget>((skill) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: odaPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: odaPrimary.withOpacity(0.5)),
                  ),
                  child: Text(
                    skill.toString(),
                    style: TextStyle(
                      color: odaPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    // Treat empty strings as null
    final displayValue = value?.trim();
    if (displayValue == null || displayValue.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasProfessionalInfo() {
    // Treat empty strings as null
    final currentRole = _userData!['currentRole']?.toString().trim();
    final company = _userData!['company']?.toString().trim();
    final profession = _userData!['profession']?.toString().trim();
    
    return (currentRole != null && currentRole.isNotEmpty) ||
        (company != null && company.isNotEmpty) ||
        (profession != null && profession.isNotEmpty);
  }

  bool _hasSkills() {
    final skills = _userData!['skills'];
    return skills != null && skills is List && skills.isNotEmpty;
  }
}
