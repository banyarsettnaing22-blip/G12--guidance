import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:ai_project/services/appwrite_service.dart';
import 'package:ai_project/views/userPage.dart';
import 'data/offline_data.dart';

// ==========================================
// 1. App Entry Point
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Flutter Web တွင် static asset အဖြစ် ချောမွေ့စွာ ဖတ်ယူနိုင်ရန် assets/env ကို သုံးပါသည်
  await dotenv.load(fileName: "assets/env");
  
  runApp(const MyApp());
}

// ==========================================
// 2. Theme & Base Config
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A769E),
        scaffoldBackgroundColor: const Color(0xFF1FC2D8),
      ),
      home: const LandingScreen(),
    );
  }
}

// ==========================================
// 3. App Logo Component
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
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Logo Missing\nCheck pubspec.yaml',
            style: TextStyle(fontSize: 11, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

// ==========================================
// 4. Unified 3D Button
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
    this.backgroundColor = const Color(0xFF87CE52),
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1B3B36),
              offset: Offset(4, 5),
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
            fontWeight: FontWeight.w600,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 220),
                const SizedBox(height: 70),
                Unified3DButton(
                  width: 240,
                  label: 'login',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Unified3DButton(
                  width: 240,
                  label: 'Guest',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const DashboardScreen(isPaidUser: false),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'forgot_password',
                    style: TextStyle(
                      color: Color(0xFF0033CC),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF0033CC),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
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

    if (loginId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username/email and password.'),
          backgroundColor: Colors.orange,
        ),
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
        MaterialPageRoute(builder: (context) => HomeView()),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),
              const AppLogo(size: 160),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Username / Email:',
                  labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Password:',
                  labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Unified3DButton(label: 'Login', onPressed: _handleLogin),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. DASHBOARD SCREEN
// ==========================================
class DashboardScreen extends StatelessWidget {
  final bool isPaidUser;
  const DashboardScreen({super.key, this.isPaidUser = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LandingScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SettingsScreen(isPaidUser: isPaidUser),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Center(child: AppLogo(size: 140)),
              const Spacer(),
              Unified3DButton(
                label: 'BOOKS',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BooksScreen(isPaidUser: isPaidUser),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Unified3DButton(
                label: 'old questions',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YearsScreen(isPaidUser: isPaidUser),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Unified3DButton(
                label: 'SETTINGS & PROFILE',
                backgroundColor: const Color(0xFF4A769E),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettingsScreen(isPaidUser: isPaidUser),
                    ),
                  );
                },
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 8. SETTINGS & PROFILE SCREEN
// ==========================================
class SettingsScreen extends StatefulWidget {
  final bool isPaidUser;
  const SettingsScreen({super.key, this.isPaidUser = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _offlineSync = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const AppLogo(size: 70),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SETTINGS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: primary,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isPaidUser ? 'Paid Member' : 'Guest User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.isPaidUser
                                  ? 'Full Access'
                                  : 'Limited Access',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Offline Mode Sync'),
                      subtitle: const Text('Keep local book caches ready'),
                      value: _offlineSync,
                      activeColor: primary,
                      onChanged: (val) => setState(() => _offlineSync = val),
                    ),
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Updates on new questions'),
                      value: _notifications,
                      activeColor: primary,
                      onChanged: (val) => setState(() => _notifications = val),
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Storage',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Clear Cached PDFs'),
                      subtitle: const Text('Delete temporary offline documents'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Local PDF cache cleared.'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 32),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        widget.isPaidUser ? 'Log Out' : 'Exit to Landing Screen',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LandingScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 9. BOOKS CATEGORY SCREEN
// ==========================================
class BooksScreen extends StatelessWidget {
  final bool isPaidUser;
  const BooksScreen({super.key, this.isPaidUser = false});

  @override
  Widget build(BuildContext context) {
    final books = OfflineData.offlineBooks;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const AppLogo(size: 90),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                        child: Text(
                          isPaidUser ? 'Logout' : 'Login',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BOOKS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final bool isOffline = book['is_offline'] == 'true' || 
                                         (book['asset_path'] != null && book['asset_path']!.isNotEmpty);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Unified3DButton(
                      label: isOffline ? "${book['subject_code']!} (Offline)" : "${book['subject_code']!} ☁️",
                      backgroundColor: isOffline ? const Color(0xFF87CE52) : const Color(0xFFFF5A5A),
                      textColor: isOffline ? Colors.black : Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              title: book['display_name']!,
                              assetPath: book['asset_path'],
                              fileId: book['file_id'], 
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 10. OLD QUESTIONS YEAR SCREEN
// ==========================================
class YearsScreen extends StatelessWidget {
  final bool isPaidUser;
  const YearsScreen({super.key, this.isPaidUser = false});

  final List<String> years = const ['2023-24', '2024-25', '2025-26'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const AppLogo(size: 90),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                        child: Text(
                          isPaidUser ? 'Logout' : 'Login',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'old questions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: years.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Unified3DButton(
                      label: years[index],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionsSubjectScreen(
                              year: years[index],
                              isPaidUser: isPaidUser,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 11. QUESTIONS SUBJECT SCREEN
// ==========================================
class QuestionsSubjectScreen extends StatelessWidget {
  final String year;
  final bool isPaidUser;
  const QuestionsSubjectScreen({
    super.key,
    required this.year,
    this.isPaidUser = false,
  });

  final List<String> subjects = const [
    'myanmar',
    'eng',
    'math',
    'chem',
    'phy',
    'bio',
    'eco',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const AppLogo(size: 90),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                        child: Text(
                          isPaidUser ? 'Logout' : 'Login',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          year,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'old questions',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Unified3DButton(
                      label: subjects[index],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              title: '$year - ${subjects[index]}',
                              assetPath: 'assets/books/${subjects[index]}.pdf',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 12. PDF DETAIL SCREEN (Hybrid: Local & Cloud)
// ==========================================
class DetailScreen extends StatefulWidget {
  final String title;
  final String? assetPath;
  final String? fileId;

  const DetailScreen({
    super.key,
    required this.title,
    this.assetPath,
    this.fileId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '6a85ef5f003d10eb304d';
  static const String bucketId = '6a8afd05000ffb3c89a5';

  Uint8List? _cloudPdfBytes;
  bool _isLoading = false;
  String? _errorMessage;
  double _downloadProgress = 0.0;
  
  StreamSubscription? _downloadSubscription;

  @override
  void initState() {
    super.initState();
    final hasAsset = widget.assetPath != null && widget.assetPath!.isNotEmpty;
    final hasFileId = widget.fileId != null && widget.fileId!.isNotEmpty;

    if (!hasAsset && hasFileId) {
      _fetchCloudPdf();
    }
  }

  @override
  void dispose() {
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
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: isLocalAsset ? const Color(0xFF76C843) : const Color(0xFFFF5A5A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Builder(
            builder: (context) {
              // ၁။ Local ဖိုင်ဆိုလျှင် - RAM မစားသော တိုက်ရိုက် Asset စနစ်ကို အသုံးပြုမည်
              if (isLocalAsset) {
                return SfPdfViewer.asset(
                  widget.assetPath!,
                  canShowScrollHead: true,
                );
              }

              // ၂။ Cloud ဖိုင်များအတွက် Loading
              if (_isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _downloadProgress > 0 ? _downloadProgress : null,
                        color: const Color(0xFFFF5A5A),
                      ),
                      const SizedBox(height: 16),
                      Text('Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
                );
              }

              // ၃။ Cloud ဖိုင် Error ပြသခြင်း
              if (_errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCloudPdf,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              // ၄။ Cloud မှ Memory သို့ ဝင်လာပါက ဖတ်မည်
              if (_cloudPdfBytes != null) {
                return SfPdfViewer.memory(_cloudPdfBytes!, canShowScrollHead: true);
              }

              return const Center(child: Text('PDF File Not Found!', style: TextStyle(color: Colors.black54)));
            },
          ),
        ),
      ),
    );
  }
}