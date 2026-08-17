import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'data/offline_data.dart';

// ==========================================
// App စတင်အလုပ်လုပ်မည့် အဓိက Entry Point
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pqnkevxcvtwoisnrimwp.supabase.co',
    anonKey: 'sb_publishable_vJrLcBZFL8Ae8tdJ7htXeA_UPSXrYF9',
  );

  runApp(const MyApp());
}

// ==========================================
// App တစ်ခုလုံး၏ အခြေခံ အပြင်အဆင် (Theme) သတ်မှတ်ခြင်း
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
        // App တစ်ခုလုံးရှိ စာမျက်နှာတိုင်းအတွက် နောက်ခံအရောင်ကို Cyan Blue သတ်မှတ်ခြင်း
        scaffoldBackgroundColor: const Color(0xFF1FC2D8), 
      ),
      home: const LandingScreen(),
    );
  }
}

// ==========================================
// App Logo Component
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
// နေရာတိုင်းတွင် အသုံးပြုမည့် 3D Shadow ခလုတ် (Unified 3D Button)
// ==========================================
class Unified3DButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width; // အကျယ် သတ်မှတ်ရန် (မထည့်ပါက မျက်နှာပြင်အပြည့်ယူမည်)

  const Unified3DButton({
    super.key, 
    required this.label, 
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity, 
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF87CE52), // အစိမ်းရောင် နောက်ခံ
          borderRadius: BorderRadius.circular(10), // ထောင့်ဝိုင်း
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1B3B36), // အမည်း/အစိမ်းရင့်ရောင် အရိပ် (Solid Shadow)
              offset: Offset(4, 5), 
              blurRadius: 0, 
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 1. LANDING SCREEN 
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
                        builder: (context) => const DashboardScreen(isPaidUser: false),
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
// 2. LOGIN INPUT SCREEN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final isPaid = await _supabaseService.loginPaidUser(email, password);
    setState(() => _isLoading = false);

    if (isPaid && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(isPaidUser: true),
        ),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed or this is not an active Paid account!'),
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Unified3DButton(
                      label: 'Login',
                      onPressed: _handleLogin,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. MAIN DASHBOARD SCREEN 
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LandingScreen()),
                      );
                    }
                  },
                ),
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
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. BOOKS CATEGORY SCREEN 
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const AppLogo(size: 90), 
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: Text(
                          isPaidUser ? 'Logout' : 'Login',
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BOOKS',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: books.length, 
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0), // အရိပ်လွတ်စေရန် အောက်ခြေ Padding တိုးထားသည်
                    child: Unified3DButton(
                      label: book['subject_code']!,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              title: book['display_name']!,
                              assetPath: book['asset_path'],
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
// 5. OLD QUESTIONS YEAR SCREEN 
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const AppLogo(size: 90),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: Text(
                          isPaidUser ? 'Logout' : 'Login',
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'old questions',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
// 6. QUESTIONS SUBJECT SCREEN 
// ==========================================
class QuestionsSubjectScreen extends StatelessWidget {
  final String year; 
  final bool isPaidUser;
  const QuestionsSubjectScreen({super.key, required this.year, this.isPaidUser = false});

  final List<String> subjects = const [
    'myanmar', 'eng', 'math', 'chem', 'phy', 'bio', 'eco',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const AppLogo(size: 90),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: Text(
                          isPaidUser ? 'Logout' : 'Login',
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        Text(
                          year,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
// 7. FINAL CORE DETAIL VIEW 
// ==========================================
class DetailScreen extends StatelessWidget {
  final String title; 
  final String? assetPath; 

  const DetailScreen({
    super.key,
    required this.title,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const AppLogo(size: 90),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      title.contains('-') ? title.split(' - ')[1] : title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    if (assetPath != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'File: $assetPath',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
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