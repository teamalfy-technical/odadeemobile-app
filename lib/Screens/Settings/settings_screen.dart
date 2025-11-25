import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/components/footer_nav.dart';
import 'package:odadee/components/web_view_page.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Authentication/SignIn/sgin_in_screen.dart';
import 'package:odadee/Screens/Settings/change_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  String _appVersion = '';
  String _buildNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? notificationStatus = prefs.getString("notification");
    setState(() {
      _notificationsEnabled = notificationStatus == "1";
      _isLoading = false;
    });
  }

  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      print('Error loading app info: $e');
    }
  }

  Future<void> _updateNotificationStatus(bool newValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    try {
      final authService = AuthService();
      final response = await authService.authenticatedRequest(
        'POST',
        '/api/settings',
        body: {'push_notification': newValue ? '1' : '0'},
      );

      if (response.statusCode == 200) {
        await prefs.setString("notification", newValue ? '1' : '0');
        setState(() {
          _notificationsEnabled = newValue;
        });
        _showSuccess('Notification settings updated');
      } else {
        _showError('Failed to update notification settings');
      }
    } catch (error) {
      print('Error updating notification settings: $error');
      _showError('Failed to update notification settings');
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      isDangerous: false,
    );

    if (confirmed) {
      try {
        final authService = AuthService();
        await authService.logout();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        _showError('Logout failed. Please try again.');
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete Account',
      message:
          'Are you absolutely sure? This will permanently delete your account and all associated data. This action cannot be undone.',
      confirmText: 'Delete My Account',
      isDangerous: true,
    );

    if (confirmed) {
      // Second confirmation for extra safety
      final doubleConfirmed = await _showConfirmDialog(
        title: 'Final Confirmation',
        message:
            'This is your last chance. Your account will be permanently deleted. Are you absolutely certain?',
        confirmText: 'Yes, Delete Forever',
        isDangerous: true,
      );

      if (doubleConfirmed) {
        _showLoadingDialog();
        
        try {
          final authService = AuthService();
          final response = await authService.authenticatedRequest(
            'DELETE',
            '/api/auth/delete-account',
          );

          Navigator.pop(context); // Close loading dialog

          if (response.statusCode == 200) {
            await authService.logout();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (route) => false,
              );
            }
          } else {
            _showError('Failed to delete account. Please contact support.');
          }
        } catch (e) {
          Navigator.pop(context); // Close loading dialog
          _showError('Failed to delete account. Please try again.');
        }
      }
    }
  }

  Future<void> _handleExportData() async {
    final confirmed = await _showConfirmDialog(
      title: 'Export Data',
      message: 'We will send a copy of your data to your registered email address. This may take a few minutes.',
      confirmText: 'Export My Data',
      isDangerous: false,
    );

    if (!confirmed) return;

    _showLoadingDialog();
    
    try {
      final authService = AuthService();
      final response = await authService.authenticatedRequest(
        'POST',
        '/api/users/export-data',
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 202) {
        // 200 = immediate export, 202 = queued for processing
        _showDialog(
          title: 'Export Requested',
          message: 'Your data export has been initiated. You will receive an email with a download link within the next 24 hours.',
          isSuccess: true,
        );
      } else if (response.statusCode == 429) {
        _showError('Too many export requests. Please try again later.');
      } else {
        _showError('Failed to export data. Please contact support if this persists.');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Export data error: $e');
      _showError('Failed to export data. Please check your internet connection and try again.');
    }
  }

  void _showDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1e293b),
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: odaSecondary)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleClearCache() async {
    final confirmed = await _showConfirmDialog(
      title: 'Clear Cache',
      message: 'This will clear cached images and temporary data. Your login session will be preserved.',
      confirmText: 'Clear Cache',
      isDangerous: false,
    );

    if (confirmed) {
      try {
        final prefs = await SharedPreferences.getInstance();
        
        // Preserve critical auth and settings data
        final notification = prefs.getString('notification');
        final accessToken = prefs.getString('access_token');
        final refreshToken = prefs.getString('refresh_token');
        final userId = prefs.getString('user_id');
        final userEmail = prefs.getString('user_email');
        final userFirstName = prefs.getString('user_first_name');
        final userLastName = prefs.getString('user_last_name');
        
        // Clear all preferences
        await prefs.clear();
        
        // Restore preserved data
        if (notification != null) await prefs.setString('notification', notification);
        if (accessToken != null) await prefs.setString('access_token', accessToken);
        if (refreshToken != null) await prefs.setString('refresh_token', refreshToken);
        if (userId != null) await prefs.setString('user_id', userId);
        if (userEmail != null) await prefs.setString('user_email', userEmail);
        if (userFirstName != null) await prefs.setString('user_first_name', userFirstName);
        if (userLastName != null) await prefs.setString('user_last_name', userLastName);
        
        _showSuccess('Cache cleared successfully');
      } catch (e) {
        _showError('Failed to clear cache');
      }
    }
  }

  Future<void> _openPrivacyPolicy() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          title: 'Privacy Policy',
          url: 'https://odadee.net/privacy-policy',
        ),
      ),
    );
  }

  Future<void> _openTermsOfService() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          title: 'Terms of Service',
          url: 'https://odadee.net/terms-service',
        ),
      ),
    );
  }

  Future<void> _openLicenses() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Theme(
          data: ThemeData.dark(),
          child: LicensePage(
            applicationName: 'Odadee',
            applicationVersion: '$_appVersion ($_buildNumber)',
            applicationLegalese: '© 2024 PRESEC Alumni Association',
          ),
        ),
      ),
    );
  }

  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@odadee.net',
      query: 'subject=Odadee Support Request',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showError('Could not open email app');
      }
    } catch (e) {
      _showError('Could not open email app');
    }
  }

  Future<void> _rateApp() async {
    String storeUrl;
    
    if (kIsWeb) {
      _showError('Please rate us on your device\'s app store');
      return;
    }

    try {
      if (Platform.isAndroid) {
        storeUrl = 'https://play.google.com/store/apps/details?id=com.odadee.app';
      } else if (Platform.isIOS) {
        storeUrl = 'https://apps.apple.com/app/idXXXXXXXXX'; // Replace with actual App Store ID
      } else {
        _showError('Platform not supported');
        return;
      }

      final Uri url = Uri.parse(storeUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not open app store');
      }
    } catch (e) {
      _showError('Could not open app store');
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isDangerous,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1e293b),
          title: Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDangerous ? Colors.red : odaPrimary,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(odaSecondary),
          ),
        );
      },
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: odaBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: odaBackground),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: odaBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(odaSecondary),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 100),
                          child: Column(
                            children: [
                              _buildAccountSection(),
                              _buildPreferencesSection(),
                              _buildDataPrivacySection(),
                              _buildLegalSection(),
                              _buildSupportSection(),
                              _buildAboutSection(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            FooterNav(activeTab: 'settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'Account',
      children: [
        _buildSettingsItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfileScreen()),
            );
          },
        ),
        _buildSettingsItem(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update or set your password',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
            );
          },
        ),
        _buildSettingsItem(
          icon: Icons.download_outlined,
          title: 'Export My Data',
          subtitle: 'Download a copy of your data',
          onTap: _handleExportData,
        ),
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Logout',
          onTap: _handleLogout,
        ),
        _buildSettingsItem(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          textColor: Colors.red,
          onTap: _handleDeleteAccount,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.notifications_outlined, color: Colors.white70, size: 24),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Receive updates and announcements',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: _notificationsEnabled,
                onChanged: _updateNotificationStatus,
                activeColor: odaSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataPrivacySection() {
    return _buildSection(
      title: 'Data & Privacy',
      children: [
        _buildSettingsItem(
          icon: Icons.cleaning_services_outlined,
          title: 'Clear Cache',
          subtitle: 'Free up storage space',
          onTap: _handleClearCache,
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return _buildSection(
      title: 'Legal',
      children: [
        _buildSettingsItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: _openPrivacyPolicy,
        ),
        _buildSettingsItem(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: _openTermsOfService,
        ),
        _buildSettingsItem(
          icon: Icons.code_outlined,
          title: 'Open Source Licenses',
          onTap: _openLicenses,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support',
      children: [
        _buildSettingsItem(
          icon: Icons.email_outlined,
          title: 'Contact Support',
          subtitle: 'support@odadee.net',
          onTap: _contactSupport,
        ),
        _buildSettingsItem(
          icon: Icons.star_outline,
          title: 'Rate the App',
          subtitle: 'Show us some love',
          onTap: _rateApp,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset('assets/images/oda_logo.png', height: 60),
              SizedBox(height: 12),
              Text(
                'Odadee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Version $_appVersion ($_buildNumber)',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '© 2024 PRESEC Alumni Association',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Connecting PRESEC alumni worldwide',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: odaSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFF1e293b),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.white70, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }
}
