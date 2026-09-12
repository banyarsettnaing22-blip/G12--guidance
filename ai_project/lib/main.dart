import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_project/services/appwrite_service.dart';
import 'data/offline_data.dart';

// သင်၏ Screen အသစ်များကို လှမ်းခေါ်ခြင်း (views folder ထဲတွင် ရှိရမည်)
import 'package:ai_project/views/my_account_screen.dart';
import 'package:ai_project/views/note_screen.dart';
import 'package:ai_project/views/ask_ai_screen.dart';
import 'package:ai_project/views/quiz_screen.dart';

// ==========================================
// 1. App Entry Point
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env");
  runApp(const MyApp());
}

// ==========================================
// 2. Global Design Constants & Theme
// ==========================================
class AppDesign {
  static const Color primaryBlue = Color(0xFF2948FF);
  static const Color gradientTop = Color(0xFF0D0B2B);
  static const Color gradientBottom = Color(0xFF1E2CB8);
  static const Color cyanAccent = Color(0xFF4EE3FF);
  static const Color cardWhite = Color(0xFFF7FAFC);

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientBottom],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: AppDesign.primaryBlue,
        scaffoldBackgroundColor: AppDesign.gradientTop,
      ),
      home: const LandingScreen(),
    );
  }
}

// ==========================================
// 3. Logo Component
// ==========================================
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo1.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.school, size: 60, color: Colors.white70),
        );
      },
    );
  }
}

// ==========================================
// 4. 3D Extruded Button
// ==========================================
class Unified3DButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final Color backgroundColor;
  final Color textColor;

  const Unified3DButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.backgroundColor = AppDesign.cardWhite,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. LANDING SCREEN
// ==========================================
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3D8E2),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 170),
                        const SizedBox(height: 48),
                        Unified3DButton(
                          label: 'login',
                          backgroundColor: AppDesign.primaryBlue,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        Unified3DButton(
                          label: 'Guest',
                          backgroundColor: AppDesign.cyanAccent,
                          textColor: Colors.black,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DashboardScreen(isPaidUser: false)),
                            );
                          },
                        ),
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'forgot_password',
                            style: TextStyle(
                              color: Color(0xFF2948FF),
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. LOGIN SCREEN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _appwriteService = AppwriteService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final loginId = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (loginId.isEmpty && password.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
        (route) => false,
      );
      return;
    }

    setState(() => _isLoading = true);

    final isPaid = await _appwriteService.loginPaidUser(loginId, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isPaid) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed! Please check your credentials.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppDesign.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'G-12 Guidance',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3D8E2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppLogo(size: 150),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Username:',
                              labelStyle: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppDesign.primaryBlue, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Password:',
                              labelStyle: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppDesign.primaryBlue, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Text(
                                'forgot_password',
                                style: TextStyle(color: Color(0xFF2948FF), fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator(color: AppDesign.primaryBlue))
                              : Unified3DButton(
                                  label: 'login',
                                  backgroundColor: AppDesign.primaryBlue,
                                  textColor: Colors.white,
                                  onPressed: _handleLogin,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. HOME DASHBOARD (HomeView)
// ==========================================
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('profile_image_path');
    });
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteScreen()));
      return;
    }
    if (index == 2) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen()));
      _loadProfileImage();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: const BoxDecoration(
                  color: AppDesign.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: _imagePath != null
                          ? ClipOval(
                              child: kIsWeb
                                  ? Image.network(_imagePath!, fit: BoxFit.cover)
                                  : Image.file(File(_imagePath!), fit: BoxFit.cover),
                            )
                          : const Icon(Icons.person, size: 36, color: AppDesign.primaryBlue),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Welcome', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('ThetNaung', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _build3DCard(
                              title: 'BOOKS',
                              icon: Icons.menu_book_rounded,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BooksScreen(isPaidUser: true))),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _build3DCard(
                              title: 'Old Questions',
                              icon: Icons.assignment_outlined,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const YearsScreen(isPaidUser: true))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _build3DCard(
                              title: 'Quiz',
                              icon: Icons.lightbulb_outline_rounded,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizScreen())),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _build3DCard(
                              title: 'Ask AI',
                              icon: Icons.hub_outlined,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AskAIScreen())),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildWideCyanButton('အမှတ်ပေးစည်းမျဉ်း', () {}),
                      const SizedBox(height: 16),
                      _buildWideCyanButton('Sample Questions', () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      color: AppDesign.gradientBottom,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
          _buildNavItem(icon: Icons.assignment_outlined, label: 'My_Note', index: 1),
          _buildNavItem(icon: Icons.account_circle_outlined, label: 'Profile', index: 2),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _build3DCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppDesign.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black87, offset: Offset(0, 5), blurRadius: 0)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: AppDesign.primaryBlue),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideCyanButton(String title, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppDesign.cyanAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 4), blurRadius: 0)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87))),
        ),
      ),
    );
  }
}

// ==========================================
// 8. DASHBOARD SCREEN (Guest Mode)
// ==========================================
class DashboardScreen extends StatelessWidget {
  final bool isPaidUser;
  const DashboardScreen({super.key, this.isPaidUser = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppDesign.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LandingScreen()));
                        }
                      },
                    ),
                    const Text('Guest Dashboard', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white, size: 26),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen())),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    children: [
                      const Spacer(),
                      const Center(child: AppLogo(size: 160)),
                      const Spacer(),
                      Unified3DButton(
                        label: 'BOOKS',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BooksScreen(isPaidUser: isPaidUser))),
                      ),
                      const SizedBox(height: 20),
                      Unified3DButton(
                        label: 'old questions',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => YearsScreen(isPaidUser: isPaidUser))),
                      ),
                      const SizedBox(height: 20),
                      Unified3DButton(
                        label: 'SETTINGS & PROFILE',
                        backgroundColor: AppDesign.cyanAccent,
                        textColor: Colors.black,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen())),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 9. REUSABLE GLOBAL BOTTOM NAV
// ==========================================
class GlobalBottomNav extends StatelessWidget {
  const GlobalBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppDesign.gradientBottom,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const _NavIcon(icon: Icons.home_rounded, label: 'Home'),
          ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteScreen())),
            child: const _NavIcon(icon: Icons.assignment_outlined, label: 'My_Note'),
          ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen())),
            child: const _NavIcon(icon: Icons.account_circle_outlined, label: 'Profile'),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

// ==========================================
// 10. BOOKS CATEGORY SCREEN
// ==========================================
class BooksScreen extends StatelessWidget {
  final bool isPaidUser;
  const BooksScreen({super.key, this.isPaidUser = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppDesign.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text('Books', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: Text(isPaidUser ? 'Logout' : 'Login', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  children: [
                    _buildCategoryCard(
                      title: 'Text Books',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TextBooksListScreen(isPaidUser: isPaidUser))),
                    ),
                    const SizedBox(height: 18),
                    _buildCategoryCard(title: 'Answer Books', onTap: () {}),
                    const SizedBox(height: 18),
                    _buildCategoryCard(title: 'Teacher guides', onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GlobalBottomNav(),
    );
  }

  Widget _buildCategoryCard({required String title, required VoidCallback onTap}) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppDesign.cyanAccent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black87, offset: Offset(0, 5), blurRadius: 0)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: 85,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.cloud_outlined, size: 40, color: Color(0xFF4A90E2))),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextBooksListScreen extends StatelessWidget {
  final bool isPaidUser;
  const TextBooksListScreen({super.key, this.isPaidUser = false});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> subjects = const [
      {'title': 'Myanmar Textbook', 'file': 'myanmar.pdf'},
      {'title': 'English Textbook', 'file': 'english.pdf'},
      {'title': 'Mathematic Textbook', 'file': 'mathematic.pdf'},
      {'title': 'Chemistry Textbook', 'file': 'chemistry.pdf'},
      {'title': 'Physics Textbook', 'file': 'physics.pdf'},
      {'title': 'Biology Textbook', 'file': 'biology.pdf'},
      {'title': 'Ecology Textbook', 'file': 'economic.pdf'},
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppDesign.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text('Text Books', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final sub = subjects[index];
                    return Unified3DButton(
                      label: sub['title']!,
                      backgroundColor: AppDesign.cardWhite,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              title: sub['title']!,
                              assetPath: 'assets/books/${sub['file']}',
                              isPaidUser: isPaidUser,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GlobalBottomNav(),
    );
  }
}

// ==========================================
// 11. OLD QUESTIONS YEAR SCREEN
// ==========================================
class YearsScreen extends StatelessWidget {
  final bool isPaidUser;
  const YearsScreen({super.key, this.isPaidUser = false});

  final List<String> years = const ['2023-24', '2024-25', '2025-26'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppDesign.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.assignment_outlined, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text('Old Questions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: Text(isPaidUser ? 'Logout' : 'Login', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  itemCount: years.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    return Unified3DButton(
                      label: years[index],
                      backgroundColor: AppDesign.cardWhite,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionsSubjectScreen(year: years[index], isPaidUser: isPaidUser),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GlobalBottomNav(),
    );
  }
}

// ==========================================
// 12. QUESTIONS SUBJECT SCREEN
// ==========================================
class QuestionsSubjectScreen extends StatelessWidget {
  final String year;
  final bool isPaidUser;
  const QuestionsSubjectScreen({super.key, required this.year, this.isPaidUser = false});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> subjects = const [
      {'title': 'Myanmar Questions', 'file': 'myanmar.pdf'},
      {'title': 'English Questions', 'file': 'english.pdf'},
      {'title': 'Mathematic Questions', 'file': 'mathematic.pdf'},
      {'title': 'Chemistry Questions', 'file': 'chemistry.pdf'},
      {'title': 'Physics Questions', 'file': 'physics.pdf'},
      {'title': 'Biology Questions', 'file': 'biology.pdf'},
      {'title': 'Ecology Questions', 'file': 'economic.pdf'},
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppDesign.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppDesign.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.assignment_outlined, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(year, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final sub = subjects[index];
                    return Unified3DButton(
                      label: sub['title']!,
                      backgroundColor: AppDesign.cardWhite,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              title: '$year - ${sub['title']}',
                              assetPath: 'assets/books/${sub['file']}',
                              isPaidUser: isPaidUser,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GlobalBottomNav(),
    );
  }
}

// ==========================================
// 13. PDF DETAIL SCREEN 
// ==========================================
class DetailScreen extends StatefulWidget {
  final String title;
  final String? assetPath;
  final String? fileId;
  final bool isPaidUser;

  const DetailScreen({
    super.key,
    required this.title,
    this.assetPath,
    this.fileId,
    this.isPaidUser = false,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '6a85ef5f003d10eb304d';
  static const String bucketId = '6a8afd05000ffb3c89a5';

  late PdfViewerController _pdfViewerController;
  late TextEditingController _pageNumberController;
  int _currentPage = 1;
  int _pageCount = 0;

  Uint8List? _cloudPdfBytes;
  bool _isLoading = false;
  String? _errorMessage;
  double _downloadProgress = 0.0;
  StreamSubscription? _downloadSubscription;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _pageNumberController = TextEditingController(text: '1');

    final hasAsset = widget.assetPath != null && widget.assetPath!.isNotEmpty;
    final hasFileId = widget.fileId != null && widget.fileId!.isNotEmpty;

    if (!hasAsset && hasFileId) {
      _fetchCloudPdf();
    }
  }

  @override
  void dispose() {
    _pageNumberController.dispose();
    _pdfViewerController.dispose();
    _downloadSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchCloudPdf() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _downloadProgress = 0.0;
    });

    final url = '$endpoint/storage/buckets/$bucketId/files/${widget.fileId}/view?project=$projectId';

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        final List<int> byteList = [];

        _downloadSubscription = response.stream.listen(
          (List<int> chunk) {
            byteList.addAll(chunk);
            if (contentLength > 0 && mounted) {
              setState(() {
                _downloadProgress = (byteList.length / contentLength).clamp(0.0, 1.0);
              });
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _cloudPdfBytes = Uint8List.fromList(byteList);
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => _errorMessage = 'Download Error:\n$error');
            }
          },
          cancelOnError: true,
        );
      } else {
        if (mounted) {
          setState(() => _errorMessage = 'Server Error (HTTP ${response.statusCode})');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Connection Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocalAsset = widget.assetPath != null && widget.assetPath!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B2B),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        backgroundColor: AppDesign.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rounded, color: Colors.white70, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF0D0B2B),
            child: Builder(
              builder: (context) {
                if (isLocalAsset) {
                  return SfPdfViewer.asset(
                    widget.assetPath!,
                    controller: _pdfViewerController,
                    canShowScrollHead: true,
                    onDocumentLoaded: (details) {
                      setState(() => _pageCount = details.document.pages.count);
                    },
                    onPageChanged: (details) {
                      setState(() {
                        _currentPage = details.newPageNumber;
                        _pageNumberController.text = details.newPageNumber.toString();
                      });
                    },
                  );
                }

                if (_isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _downloadProgress > 0 ? _downloadProgress : null,
                          color: AppDesign.cyanAccent,
                        ),
                        const SizedBox(height: 16),
                        Text('Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                }

                if (_errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchCloudPdf, child: const Text('Try Again')),
                      ],
                    ),
                  );
                }

                if (_cloudPdfBytes != null) {
                  return SfPdfViewer.memory(
                    _cloudPdfBytes!,
                    controller: _pdfViewerController,
                    canShowScrollHead: true,
                    onDocumentLoaded: (details) {
                      setState(() => _pageCount = details.document.pages.count);
                    },
                    onPageChanged: (details) {
                      setState(() {
                        _currentPage = details.newPageNumber;
                        _pageNumberController.text = details.newPageNumber.toString();
                      });
                    },
                  );
                }

                return const Center(child: Text('PDF File Not Found!', style: TextStyle(color: Colors.white70)));
              },
            ),
          ),
          
          // ---------------------------------
          // AI Chat Pop-up Button (Only for Paid Users)
          // ---------------------------------
          if (widget.isPaidUser)
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AIChatSheet(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppDesign.cyanAccent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(0, 3), blurRadius: 4)],
                  ),
                  child: const Icon(Icons.hub_outlined, color: Colors.black87, size: 24),
                ),
              ),
            ),
        ],
      ),
      
      // Combined Bottom Navigation: Back Button + PDF Pages
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2CB8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Exit/Back Button
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.undo_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text('Back', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            // 2. PDF Page Navigation
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
                  tooltip: 'Previous Page',
                  onPressed: _currentPage > 1 ? () => _pdfViewerController.previousPage() : null,
                ),
                SizedBox(
                  width: 48,
                  height: 32,
                  child: TextField(
                    controller: _pageNumberController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      final targetPage = int.tryParse(value);
                      if (targetPage != null && targetPage >= 1 && (_pageCount == 0 || targetPage <= _pageCount)) {
                        _pdfViewerController.jumpToPage(targetPage);
                      } else {
                        _pageNumberController.text = _currentPage.toString();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _pageCount > 0 ? '/ $_pageCount' : '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                  tooltip: 'Next Page',
                  onPressed: (_pageCount == 0 || _currentPage < _pageCount) ? () => _pdfViewerController.nextPage() : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 14. AI CHAT POP-UP SHEET (OpenAI RAG Integration)
// ==========================================
class AIChatSheet extends StatefulWidget {
  const AIChatSheet({super.key});

  @override
  State<AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<AIChatSheet> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello! I am your AI Assistant. Ask me anything about the G12 guidance.", "isAI": true},
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final userText = _chatController.text.trim();
    if (userText.isEmpty) return;
    
    setState(() {
      _messages.add({"text": userText, "isAI": false});
      _chatController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // 1. Read the RAG context document from assets
      String contextText = "";
      try {
        contextText = await rootBundle.loadString('assets/texts/project g12 guidance.txt');
      } catch (e) {
        setState(() {
          _messages.add({"text": "System Error: Cannot find 'project g12 guidance.txt'. Please stop the app, run 'flutter clean', and restart.", "isAI": true});
          _isTyping = false;
        });
        _scrollToBottom();
        return;
      }

      if (contextText.trim().isEmpty) {
        setState(() {
          _messages.add({"text": "System Error: The textbook file is empty.", "isAI": true});
          _isTyping = false;
        });
        _scrollToBottom();
        return;
      }

      // 2. Get OpenAI API Key
      final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
         setState(() {
          _messages.add({"text": "Error: OPENAI_API_KEY is missing in your assets/env file.", "isAI": true});
          _isTyping = false;
        });
        _scrollToBottom();
        return;
      }

      // 3. Prepare the HTTP request to OpenAI
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      // 4. Construct the Payload (System Prompt + User Question)
      final body = jsonEncode({
        "model": "gpt-4o-mini", // Upgraded to support 128,000 tokens
        "messages": [
          {
            "role": "system",
            "content": "You are a friendly and helpful AI Academic Assistant for a Grade 12 Guidance App. Use ONLY the information from the Context Document below to answer the user's questions. If the answer is not explicitly in the document, politely apologize and say you can only answer based on the Grade 12 syllabus provided.\n\nContext Document:\n$contextText"
          },
          {
            "role": "user",
            "content": userText
          }
        ],
        "temperature": 0.3 
      });

      // 5. Send Request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add({"text": botReply.trim(), "isAI": true});
          _isTyping = false;
        });
      } else {
        // Handle API errors (like quota exceeded, invalid key, etc.)
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 'Unknown API Error';
        setState(() {
          _messages.add({"text": "OpenAI Error: $errorMsg", "isAI": true});
          _isTyping = false;
        });
      }
      _scrollToBottom();

    } catch (e) {
      setState(() {
        _messages.add({"text": "Network Error: Could not connect to OpenAI. Check your internet connection.", "isAI": true});
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65, 
        decoration: const BoxDecoration(
          color: Color(0xFF0D0B2B), 
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF2948FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.hub_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text('AI Assistant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isAI = msg['isAI'];
                  return Align(
                    alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isAI ? const Color(0xFF1E2CB8) : const Color(0xFF4EE3FF),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isAI ? const Radius.circular(0) : const Radius.circular(16),
                          bottomRight: isAI ? const Radius.circular(16) : const Radius.circular(0),
                        ),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: isAI ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("AI is thinking...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, offset: Offset(0, -2), blurRadius: 4),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(), 
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isTyping ? null : _sendMessage,
                    child: CircleAvatar(
                      backgroundColor: _isTyping ? Colors.grey : const Color(0xFF4EE3FF),
                      child: const Icon(Icons.send, color: Colors.black87, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}