import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/user_service.dart';
import 'package:odadee/components/authenticated_image.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _currentRoleController;
  late TextEditingController _companyController;
  late TextEditingController _professionController;
  late TextEditingController _skillsController;
  
  bool _openToMentor = false;
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentUser['bio'] ?? '');
    _phoneController = TextEditingController(text: widget.currentUser['phoneNumber'] ?? '');
    _locationController = TextEditingController(text: widget.currentUser['location'] ?? '');
    _currentRoleController = TextEditingController(text: widget.currentUser['currentRole'] ?? '');
    _companyController = TextEditingController(text: widget.currentUser['company'] ?? '');
    _professionController = TextEditingController(text: widget.currentUser['profession'] ?? '');
    
    final skills = widget.currentUser['skills'];
    if (skills is List) {
      _skillsController = TextEditingController(text: skills.join(', '));
    } else {
      _skillsController = TextEditingController(text: '');
    }
    
    _openToMentor = widget.currentUser['openToMentor'] ?? false;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _currentRoleController.dispose();
    _companyController.dispose();
    _professionController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  String? _getProfileImageUrl() {
    final profileImagePath = widget.currentUser['profileImage'];
    if (profileImagePath == null || profileImagePath.toString().trim().isEmpty) {
      return null;
    }
    // Convert relative path to full URL
    return profileImagePath.toString().startsWith('http')
        ? profileImagePath.toString()
        : 'https://odadee-connect.replit.app/$profileImagePath';
  }

  Widget _buildProfileImageWidget() {
    if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }
    
    final imageUrl = _getProfileImageUrl();
    if (imageUrl != null) {
      return ClipOval(
        child: AuthenticatedImage(
          imageUrl: imageUrl,
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
        ),
      );
    }
    
    return Container(
      color: Color(0xFF1e293b),
      padding: EdgeInsets.all(30),
      child: Image.asset(
        'assets/images/oda_logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload is not supported on web yet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Picture',
              toolbarColor: odaPrimary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Profile Picture',
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _selectedImage = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> skills = [];
      if (_skillsController.text.trim().isNotEmpty) {
        skills = _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      await _userService.updateProfile(
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        currentRole: _currentRoleController.text.trim().isEmpty ? null : _currentRoleController.text.trim(),
        company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        profession: _professionController.text.trim().isEmpty ? null : _professionController.text.trim(),
        skills: skills.isEmpty ? null : skills,
        openToMentor: _openToMentor,
      );

      if (_selectedImage != null && !kIsWeb) {
        await _userService.uploadProfileImage(_selectedImage!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF0f172a),
        elevation: 0,
        iconTheme: IconThemeData(color: odaSecondary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: odaSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(odaSecondary),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Color(0xFF1e293b),
                          shape: BoxShape.circle,
                          border: Border.all(color: odaSecondary, width: 3),
                        ),
                        child: _buildProfileImageWidget(),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: odaSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Color(0xFF0f172a),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to change photo',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 32),
              
              _buildSectionTitle('About'),
              SizedBox(height: 12),
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Tell us about yourself...',
                maxLines: 4,
              ),
              SizedBox(height: 24),
              
              _buildSectionTitle('Contact Information'),
              SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+233...',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'City, Country',
              ),
              SizedBox(height: 24),
              
              _buildSectionTitle('Professional Information'),
              SizedBox(height: 12),
              _buildTextField(
                controller: _currentRoleController,
                label: 'Current Role',
                hint: 'e.g., Software Engineer',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _companyController,
                label: 'Company',
                hint: 'e.g., Tech Company Ltd',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _professionController,
                label: 'Profession',
                hint: 'e.g., Engineering, Medicine',
              ),
              SizedBox(height: 24),
              
              _buildSectionTitle('Skills'),
              SizedBox(height: 12),
              _buildTextField(
                controller: _skillsController,
                label: 'Skills',
                hint: 'e.g., JavaScript, Flutter, React (comma-separated)',
                maxLines: 2,
              ),
              SizedBox(height: 24),
              
              _buildSectionTitle('Mentorship'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open to Mentor',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Let others know you\'re available to mentor',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _openToMentor,
                      onChanged: (value) {
                        setState(() {
                          _openToMentor = value;
                        });
                      },
                      activeThumbColor: odaSecondary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: odaSecondary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Color(0xFF1e293b),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: odaPrimary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}
