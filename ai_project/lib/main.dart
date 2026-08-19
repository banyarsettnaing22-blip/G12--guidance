import 'package:flutter/material.dart';
import 'package:ai_project/services/appwrite_service.dart'; // Appwrite ချိတ်ဆက်ရန် Service
import 'data/offline_data.dart'; // Offline Data များခေါ်သုံးရန်
import 'package:ai_project/views/userPage.dart'; // GitHub မှ ယူထားသော userPage.dart

// ==========================================
// 1. App စတင်အလုပ်လုပ်မည့် အဓိက Entry Point
// ==========================================
void main() async {
  // Flutter framework ကို သေချာစွာ စတင်နိုင်ရန် ကြိုတင်ပြင်ဆင်ခြင်း
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ==========================================
// 2. App တစ်ခုလုံး၏ အခြေခံ အပြင်အဆင် (Theme)
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education App',
      debugShowCheckedModeBanner: false, // ညာဘက်အပေါ်ထောင့်က Debug စာတန်းကို ဖျောက်ထားမည်
      theme: ThemeData(
        primaryColor: const Color(0xFF4A769E),
        // App တစ်ခုလုံးရှိ စာမျက်နှာတိုင်းအတွက် နောက်ခံအရောင်ကို Cyan Blue သတ်မှတ်ခြင်း
        scaffoldBackgroundColor: const Color(0xFF1FC2D8),
      ),
      home: const LandingScreen(), // ပထမဆုံး စတင်ပွင့်လာမည့် စာမျက်နှာ
    );
  }
}

// ==========================================
// 3. App Logo Component (Logo ပုံလေး ဖော်ပြပေးမည့်အပိုင်း)
// ==========================================
class AppLogo extends StatelessWidget {
  final double size; // Logo အရွယ်အစားကို လိုသလို ပြောင်းနိုင်ရန်
  const AppLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo1.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // အကယ်၍ ပုံရှာမတွေ့ခဲ့ရင် Error အစား အောက်ပါ Box လေးကို ပြပေးပါမည်
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
// 4. Unified 3D Button (နေရာတိုင်းမှာ သုံးမည့် 3D အရိပ်ပါသော ခလုတ်)
// ==========================================
class Unified3DButton extends StatelessWidget {
  final String label; // ခလုတ်ပေါ်မှာ ပြမည့် စာသား
  final VoidCallback onPressed; // နှိပ်လိုက်လျှင် လုပ်ဆောင်မည့် အလုပ်
  final double? width; // ခလုတ် အကျယ် (မထည့်ပါက မျက်နှာပြင်အပြည့်ယူမည်)

  const Unified3DButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // ခလုတ်နှိပ်တာကို နားထောင်မည်
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF87CE52), // အစိမ်းရောင် နောက်ခံ
          borderRadius: BorderRadius.circular(10), // ထောင့်ဝိုင်း
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1B3B36), // အမည်း/အစိမ်းရင့်ရောင် အရိပ် (Solid Shadow)
              offset: Offset(4, 5), // အရိပ်ကို အောက်ဘက်နှင့် ညာဘက်သို့ အနည်းငယ် ရွှေ့ထားသည်
              blurRadius: 0, // အရိပ်ကို မဝါးစေဘဲ ပြတ်သားစွာ ထားမည်
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
// 5. LANDING SCREEN (App အစ ဝင်ဝင်ချင်း စာမျက်နှာ)
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
                const AppLogo(size: 220), // Logo ကြီးကြီးပြမည်
                const SizedBox(height: 70),

                // Login ဝင်မည့် ခလုတ်
                Unified3DButton(
                  width: 240,
                  label: 'login',
                  onPressed: () {
                    // နှိပ်လိုက်ပါက LoginScreen သို့ သွားမည်
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ဧည့်သည်အဖြစ် (Guest) ဝင်မည့် ခလုတ်
                Unified3DButton(
                  width: 240,
                  label: 'Guest',
                  onPressed: () {
                    // နှိပ်လိုက်ပါက Premium User 'မဟုတ်' သော အခြေအနေဖြင့် Dashboard သို့သွားမည်
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(isPaidUser: false),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // စကားဝှက်မေ့သွားပါက နှိပ်ရန် (လက်ရှိတွင် အလုပ်မလုပ်သေးပါ)
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
// 6. LOGIN INPUT SCREEN (Username နှင့် Password ရိုက်ထည့်ရန်)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // စာရိုက်ထည့်မည့် အကွက်များအတွက် Controller များ
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // ဤနေရာတွင် Appwrite Service ကို ခေါ်သုံးထားပါသည်
  final _appwriteService = AppwriteService();
  bool _isLoading = false; // Loading လည်နေ/မနေ သတ်မှတ်ရန်

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // Login ခလုတ်နှိပ်လိုက်သောအခါ အလုပ်လုပ်မည့် Function
  // ==========================================
  void _handleLogin() async {
    final loginId = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ၁။ စာသား လုံးဝ မရိုက်ထည့်ဘဲ Login နှိပ်ပါက တားဆီးမည် (Bypass မလုပ်တော့ပါ)
    if (loginId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username/email and password.'),
          backgroundColor: Colors.orange,
        ),
      );
      return; 
    }

    // ၂။ စာသားရိုက်ထည့်ထားပါက Appwrite Database သို့ လှမ်းစစ်ဆေးမည်
    setState(() {
      _isLoading = true;
    });

    final isPaid = await _appwriteService.loginPaidUser(loginId, password);

    // မျက်နှာပြင် ပိတ်သွားခြင်း ရှိ/မရှိ စစ်ဆေးပြီးမှ Loading ကို ရပ်တန့်မည်
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // ၃။ Database မှ အဖြေမှန်ကန်ပါက (Premium User ဖြစ်ပါက) userPage သို့ သွားမည်
    if (isPaid) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          // GitHub မှ ယူထားသော userPage.dart မှ Class နာမည်
          // (အကယ်၍ HomeView() ဖြစ်နေပါက အောက်တွင် ပြောင်းရေးပါ)
          builder: (context) => HomeView(), 
        ),
        (route) => false, // အနောက်သို့ ပြန်ဆုတ်ခွင့်မရှိအောင် ယခင်စာမျက်နှာများကို ဖျက်ပစ်မည်
      );
    } else {
      // မှားယွင်းနေပါက အောက်ခြေတွင် အနီရောင်ဖြင့် စာတန်းပြပေးမည်
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
              // နောက်သို့ပြန်ဆုတ်မည့် မြှားခလုတ် (Back Button)
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

              // Username သို့မဟုတ် Email ရိုက်ထည့်ရန် အကွက်
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

              // Password ရိုက်ထည့်ရန် အကွက်
              TextField(
                controller: _passwordController,
                obscureText: true, // စကားဝှက်များကို အမည်းစက်လေးများဖြင့် ဖုံးထားမည်
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

              // Loading ဖြစ်နေပါက အဝိုင်းလည်ပြမည်၊ မဟုတ်ပါက Login ခလုတ်ပြမည်
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
// 7. MAIN DASHBOARD SCREEN (ပင်မစာမျက်နှာ - ဧည့်သည်အဖြစ်ဝင်သူများအတွက်)
// ==========================================
class DashboardScreen extends StatelessWidget {
  final bool isPaidUser; // Premium (Paid) သုံးစွဲသူ ဟုတ်/မဟုတ် စစ်ဆေးရန်
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
              // Logout လုပ်မည့်ခလုတ် (နောက်သို့ပြန်ဆုတ်မည်)
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
              const Spacer(), // အပေါ်နှင့် အောက်ကြား နေရာအလွတ် ဖန်တီးပေးမည်

              // စာအုပ်များ (BOOKS) ကဏ္ဍသို့ သွားရန် ခလုတ်
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

              // မေးခွန်းဟောင်းများ (Old Questions) ကဏ္ဍသို့ သွားရန် ခလုတ်
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
              const Spacer(flex: 2), // အောက်ခြေဘက်တွင် နေရာပိုချန်ထားမည်
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 8. BOOKS CATEGORY SCREEN (စာအုပ်များ စာရင်း)
// ==========================================
class BooksScreen extends StatelessWidget {
  final bool isPaidUser;
  const BooksScreen({super.key, this.isPaidUser = false});

  @override
  Widget build(BuildContext context) {
    final books = OfflineData.offlineBooks; // offline_data.dart မှ စာအုပ်စာရင်းကို ဆွဲယူမည်

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // အပေါ်ဆုံးရှိ Header (Back Button, Logo, Title, Login/Logout Button)
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
                      // ပင်မ Landing Screen သို့ တိုက်ရိုက်ပြန်သွားမည့် ခလုတ်
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: Text(
                          isPaidUser ? 'Logout' : 'Login',
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  // ခေါင်းစဉ် "BOOKS" 
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

            // ဘာသာရပ် စာအုပ်များစာရင်းကို List ဖြင့် ဖော်ပြခြင်း
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0), // ခလုတ်တစ်ခုနှင့် တစ်ခုကြား အကွာအဝေး
                    child: Unified3DButton(
                      label: book['subject_code']!, // ဥပမာ - Myanmar, English စသည်ဖြင့် ပြမည်
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
// 9. OLD QUESTIONS YEAR SCREEN (ပညာသင်နှစ် ရွေးချယ်ရန်)
// ==========================================
class YearsScreen extends StatelessWidget {
  final bool isPaidUser;
  const YearsScreen({super.key, this.isPaidUser = false});

  final List<String> years = const ['2023-24', '2024-25', '2025-26']; // ရွေးချယ်နိုင်သော နှစ်များ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header အပိုင်း
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

            // ပညာသင်နှစ် ခလုတ်များကို စီစဉ်ပြသခြင်း
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
                        // နှစ်တစ်ခုကို ရွေးလိုက်ပါက ထိုနှစ်အတွက် ဘာသာရပ်ရွေးချယ်မည့် မျက်နှာပြင်သို့ သွားမည်
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
// 10. QUESTIONS SUBJECT SCREEN (မေးခွန်းဟောင်း ဘာသာရပ် ရွေးချယ်ရန်)
// ==========================================
class QuestionsSubjectScreen extends StatelessWidget {
  final String year; // ရွေးချယ်ထားသော ပညာသင်နှစ်
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
            // Header အပိုင်း (ရွေးချယ်ထားသော ပညာသင်နှစ်ကို ခေါင်းစဉ်တွင် ပြပေးထားမည်)
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
                          year, // ယခင်မျက်နှာပြင်မှ ရွေးချယ်လာသော နှစ် (ဥပမာ: 2023-24)
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

            // ဘာသာရပ်ခလုတ်များ ပြသခြင်း
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
                        // နောက်ဆုံး ဖတ်ရှုရမည့် Detail Screen သို့ သွားမည်
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
// 11. FINAL CORE DETAIL VIEW (စာအုပ် သို့မဟုတ် မေးခွန်း အသေးစိတ် ပြသမည့် မျက်နှာပြင်)
// ==========================================
class DetailScreen extends StatelessWidget {
  final String title; // ခေါင်းစဉ် (ဘာသာရပ်အမည်)
  final String? assetPath; // PDF လမ်းကြောင်း

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
            // Header အပိုင်း
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
                          'Login', // ယခုစာမျက်နှာကို ရောက်နေပါက Guest သို့မဟုတ် User အားလုံး Login ပြန်ဝင်ရန်
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
                      // '-' ပါလာပါက ဖြတ်ပြီး ဒုတိယပိုင်း (ဘာသာရပ်အမည်) ကိုသာ ပြမည်
                      title.contains('-') ? title.split(' - ')[1] : title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // အလယ်တွင် စာသားပြသခြင်း (ယခု နေရာတွင် PDF View ကို အစားထိုးနိုင်ပါသည်)
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