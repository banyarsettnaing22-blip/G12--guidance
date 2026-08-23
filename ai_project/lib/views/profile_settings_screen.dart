import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_project/main.dart';
import 'my_account_screen.dart';
import 'notifications_screen.dart';
import 'setting_view.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('profile_image_path');
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Log Out",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LandingScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Log Out",
                style: TextStyle(
                  color: Color(0xFFE57373),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: _imagePath != null
                    ? ClipOval(
                        child: kIsWeb
                            ? Image.network(_imagePath!, fit: BoxFit.cover)
                            : Image.file(File(_imagePath!), fit: BoxFit.cover),
                      )
                    : const Icon(Icons.person, size: 70, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),

            _buildProfileMenu(
              icon: Icons.person_outline,
              iconColor: const Color(0xFFF4A261),
              title: 'My Account',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAccountScreen(),
                  ),
                );
                _loadImage();
              },
            ),
            const SizedBox(height: 16),

            _buildProfileMenu(
              icon: Icons.notifications_none_outlined,
              iconColor: const Color(0xFFE76F51),
              title: 'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildProfileMenu(
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFFE76F51),
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildProfileMenu(
              icon: Icons.help_outline,
              iconColor: const Color(0xFFE76F51),
              title: 'Help Center',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Education App',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 Grade 12 Learning Assistant',
                );
              },
            ),
            const SizedBox(height: 16),

            _buildProfileMenu(
              icon: Icons.logout,
              iconColor: const Color(0xFFE76F51),
              title: 'Log Out',
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
