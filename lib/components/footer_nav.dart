import 'package:flutter/material.dart';
import 'package:odadee/Screens/Dashboard/dashboard_screen.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/constants.dart';

class FooterNav extends StatelessWidget {
  final String activeTab;

  const FooterNav({Key? key, required this.activeTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: odaSecondary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: activeTab == 'home',
              onTap: () {
                if (activeTab != 'home') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => DashboardScreen(),
                    ),
                  );
                }
              },
            ),
            _buildNavItem(
              context: context,
              icon: Icons.payment_rounded,
              label: 'Pay Dues',
              isActive: activeTab == 'pay_dues',
              onTap: () {
                if (activeTab != 'pay_dues') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => PayDuesScreen(),
                    ),
                  );
                }
              },
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings_rounded,
              label: 'Settings',
              isActive: activeTab == 'settings',
              onTap: () {
                if (activeTab != 'settings') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => SettingsScreen(),
                    ),
                  );
                }
              },
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person_rounded,
              label: 'Profile',
              isActive: activeTab == 'profile',
              onTap: () {
                if (activeTab != 'profile') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => UserProfileScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isActive ? Color(0xFF1a1a1a) : Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
