import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'data/offline_data.dart';

// ==========================================
// App စတင်အလုပ်လုပ်မည့် အဓိက Entry Point
// ==========================================
void main() async {
  // Flutter Engine နဲ့ UI တွေ ချိတ်ဆက်မှု အဆင်သင့်ဖြစ်အောင် အရင်ဆုံး ကြိုတင်လုပ်ဆောင်ပေးခြင်း
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase (Backend Database) ကို Client Key များအသုံးပြု၍ ချိတ်ဆက်ခြင်း
  await Supabase.initialize(
    url: 'https://pqnkevxcvtwoisnrimwp.supabase.co',
    anonKey: 'sb_publishable_vJrLcBZFL8Ae8tdJ7htXeA_UPSXrYF9',
  );

  // ချိတ်ဆက်မှုများ ပြီးစီးပါက MyApp ကို စတင် Run ပါမည်
  runApp(const MyApp());
}

// ==========================================
// App တစ်ခုလုံး၏ အခြေခံ အပြင်အဆင် (Theme) သတ်မှတ်ခြင်း
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // App တစ်ခုလုံးမှာ အသုံးပြုမည့် အဓိက အရောင် (အနီရောင်) ကို သတ်မှတ်ခြင်း
    final Color primaryColor = Colors.redAccent[200]!;

    return MaterialApp(
      title: 'Education App',
      debugShowCheckedModeBanner: false, // ညာဘက်အပေါ်ထောင့်က 'Debug' ဆိုတဲ့ စာတန်းလေးကို ဖျောက်ထားခြင်း
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white, // နောက်ခံအရောင်ကို အဖြူရောင်သတ်မှတ်ခြင်း
        // App တစ်ခုလုံးမှာရှိတဲ့ ElevatedButton တွေရဲ့ ပုံစံကို တစ်ခါတည်း ကြိုတင်သတ်မှတ်ထားခြင်း
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // ခလုတ်အရောင် (အနီ)
            foregroundColor: Colors.black, // ခလုတ်ပေါ်က စာသားအရောင် (အမည်း)
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            // ခလုတ်ကို ဘေးပတ်လည် ဝိုင်းနေစေရန် သတ်မှတ်ခြင်း (Circular Border)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      // App စဖွင့်ဖွင့်ချင်း ပထမဆုံး ပြသမည့် မျက်နှာပြင် (LandingScreen)
      home: const LandingScreen(),
    );
  }
}

// ==========================================
// App Logo ကို နေရာတိုင်းမှာ လွယ်ကူစွာ ပြန်သုံးနိုင်ရန် သီးသန့်ခွဲထုတ်ထားသော Widget
// ==========================================
class AppLogo extends StatelessWidget {
  final double size; // လိုဂို အရွယ်အစား
  const AppLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png', // pubspec.yaml တွင် ထည့်သွင်းထားသော လိုဂိုပုံ လမ်းကြောင်း
      width: size,
      height: size,
      fit: BoxFit.contain, // ပုံမပွတ်စေရန် အချိုးကျ ပြသပေးခြင်း
      // အကယ်၍ ပုံရှာမတွေ့ပါက (Error ဖြစ်ပါက) အစားထိုး ပြသမည့် အကွက်
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
// အကျယ်အပြည့်ရှိသော ခလုတ်များကို အလွယ်တကူ ပြန်သုံးနိုင်ရန် ဖန်တီးထားသော Button Widget
// ==========================================
class FullWidthButton extends StatelessWidget {
  final String label; // ခလုတ်ပေါ်တွင် ပြသမည့် စာသား
  final VoidCallback onPressed; // ခလုတ်နှိပ်လိုက်လျှင် အလုပ်လုပ်မည့် Function
  final bool isSquare; // ခလုတ်ကို ထောင့်ချွန် (Square) ပုံစံ လုပ်မည်/မလုပ်မည်

  const FullWidthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSquare = false, // Default အနေဖြင့် ထောင့်ဝိုင်းပုံစံ သတ်မှတ်ထားသည်
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // ခလုတ်ကို ဖုန်းစခရင် အကျယ်အပြည့်ဖြစ်စေရန်
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            // isSquare က true ဆိုလျှင် ထောင့်ချွန် (4)၊ false ဆိုလျှင် ထောင့်ဝိုင်း (30) ဖြစ်စေမည်
            borderRadius: BorderRadius.circular(isSquare ? 4 : 30),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

// ==========================================
// 1. LANDING SCREEN (Full Background Logo & Gradient UI)
// ==========================================
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // နောက်ခံအရောင်အဖြစ် အဖြူရောင်ထားရှိခြင်း
      backgroundColor: Colors.white,
      // Stack ကို အသုံးပြု၍ အလွှာလိုက် (Layer) ထပ်တင်မည်
      body: Stack(
        children: [
          // အလွှာ (၁) - အောက်ဆုံးတွင် Logo ပုံကို မျက်နှာပြင်အပြည့် (Full Screen) ထည့်သွင်းခြင်း
          Positioned.fill(
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover, // ပုံကို Screen အပြည့်ဆွဲဆန့်ပေးမည်
              errorBuilder: (context, error, stackTrace) {
                // အကယ်၍ ပုံမရှိခဲ့ပါက ပြသမည့် အရန်အရောင်
                return Container(color: Colors.grey[200]);
              },
            ),
          ),
          
          // အလွှာ (၂) - ပုံပေါ်မှနေ၍ Transparent Gradient (အကြည်မှ အဖြူရောင်သို့ ပြောင်းသွားသော အရောင်) အုပ်ပေးခြင်း
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, // အပေါ်ဘက်မှ စတင်မည်
                  end: Alignment.bottomCenter, // အောက်ဘက်သို့ သွားမည်
                  colors: [
                    Colors.white.withOpacity(0.1), // အပေါ်ပိုင်းတွင် ပုံကို မြင်ရစေရန် အကြည်ရောင်ထားမည်
                    Colors.white.withOpacity(0.7), // အလယ်ပိုင်းတွင် အနည်းငယ် ဖြူလာမည်
                    Colors.white, // အောက်ခြေ ခလုတ်များနေရာတွင် အဖြူရောင်အပြည့် ဖြစ်သွားမည်
                  ],
                  stops: const [0.0, 0.5, 1.0], // အရောင်ပြောင်းလဲမည့် နေရာအချိုးအစားများ
                ),
              ),
            ),
          ),

          // အလွှာ (၃) - အပေါ်ဆုံးတွင် ခလုတ် (Buttons) များကို အောက်ခြေ၌ နေရာချခြင်း
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // ခလုတ်များကို အောက်ခြေသို့ ကပ်ပေးမည်
                children: [
                  // Log In ဝင်ရန် ခလုတ်
                  FullWidthButton(
                    label: 'Log In',
                    isSquare: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Guest အနေဖြင့် ဝင်ရန် ခလုတ်
                  FullWidthButton(
                    label: 'Guest',
                    isSquare: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(isPaidUser: false),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40), // အောက်ခြေမှ နေရာအနည်းငယ် ခြားထားခြင်း
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. LOGIN INPUT SCREEN (Email/Password ရိုက်ထည့်ပြီး အကောင့်ဝင်ရန် စာမျက်နှာ)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ရိုက်ထည့်လိုက်သော Email နှင့် Password များကို ဖမ်းယူသိမ်းဆည်းမည့် Controllers များ
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isLoading = false; // Loading လည်နေခြင်း ရှိ/မရှိ စစ်ဆေးရန်

  @override
  void dispose() {
    // စာမျက်နှာ ပိတ်သွားချိန်တွင် မှတ်ဉာဏ်(Memory) မစားစေရန် Controller များကို ရှင်းလင်းခြင်း
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // အကောင့်ဝင်ရန် ခလုတ်နှိပ်လိုက်ချိန်တွင် အလုပ်လုပ်မည့် Function
  void _handleLogin() async {
    setState(() => _isLoading = true); // Loading စတင်ပြသသည်
    
    // ရိုက်ထည့်လိုက်သော စာသားများ၏ ရှေ့နောက်ရှိ ကွက်လပ်(Space) များကို ဖြတ်ထုတ်ခြင်း (trim)
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Supabase သို့ ပို့၍ Paid User ဟုတ်/မဟုတ် စစ်ဆေးခြင်း
    final isPaid = await _supabaseService.loginPaidUser(email, password);
    setState(() => _isLoading = false); // Loading ပိတ်လိုက်သည်

    if (isPaid && mounted) {
      // မှန်ကန်ပါက DashboardScreen သို့ သွားမည်။ 
      // pushAndRemoveUntil ကို သုံးထားသောကြောင့် ယခင်မှတ်တမ်းများကို ရှင်းထုတ်မည် (Back ပြန်ထွက်၍မရတော့ပါ)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(isPaidUser: true),
        ),
        (route) => false,
      );
    } else if (mounted) {
      // မှားယွင်းပါက အနီရောင် Error စာသားပြသခြင်း
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
    final color = Theme.of(context).primaryColor;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // ယခင်စာမျက်နှာ (LandingScreen) သို့ ပြန်သွားမည့် Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFFF5A5A), size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),
              const AppLogo(size: 160),
              const SizedBox(height: 40),
              
              // Email ရိုက်ထည့်ရန် အကွက်
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Username / Email:',
                  labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Password ရိုက်ထည့်ရန် အကွက် (obscureText ပါသောကြောင့် စာသားများကို ဖုံးကွယ်ထားမည်)
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password:',
                  labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              // Loading ဖြစ်နေချိန်တွင် Progress Indicator ပြ၍ မဟုတ်ပါက Login ခလုတ်ပြမည်
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FullWidthButton(
                      label: 'Login',
                      isSquare: true,
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
// 3. MAIN DASHBOARD SCREEN (BOOKS နှင့် old questions ရွေးရန် စာမျက်နှာ)
// ==========================================
class DashboardScreen extends StatelessWidget {
  final bool isPaidUser; // ပိုက်ဆံပေးထားသော User ဟုတ်/မဟုတ် လက်ခံရန်
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
              // ယခင်စာမျက်နှာသို့ ပြန်သွားမည့် Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFFF5A5A), size: 28),
                  onPressed: () {
                    // Back ထွက်လို့ရရင် ထွက်မည်၊ မရပါက LandingScreen သို့ အတင်း ပြန်ပို့မည်
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
              
              // စာအုပ်များကြည့်ရန် BooksScreen သို့ သွားမည့် ခလုတ်
              FullWidthButton(
                label: 'BOOKS',
                isSquare: false, // ထောင့်ဝိုင်းပုံစံ
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
              
              // မေးခွန်းဟောင်းများကြည့်ရန် YearsScreen သို့ သွားမည့် ခလုတ်
              FullWidthButton(
                label: 'old questions',
                isSquare: false,
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
// 4. BOOKS CATEGORY SCREEN (စာအုပ်ဘာသာရပ်များ စာရင်းပြသမည့် စာမျက်နှာ)
// ==========================================
class BooksScreen extends StatelessWidget {
  final bool isPaidUser;
  const BooksScreen({super.key, this.isPaidUser = false});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final books = OfflineData.offlineBooks; // Local File ထဲမှ စာအုပ်အချက်အလက်များကို ယူဆောင်ခြင်း

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header Bar အပိုင်း (ခေါင်းစဉ်များကို အလယ်တည့်တည့်ဖြစ်စေရန် Stack ဖြင့် ရေးထားသည်)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Stack(
                alignment: Alignment.center, // Stack အောက်ရှိ Widget များအားလုံး အလယ်တည့်တည့်ဖြစ်စေမည်
                children: [
                  // ဘယ်ဘက် (Back Button, Logo) နှင့် ညာဘက် (Login/Logout) ကို နေရာချထားခြင်း
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFFFF5A5A), size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const AppLogo(size: 90), 
                        ],
                      ),
                      // ပထမဆုံး စာမျက်နှာ(LandingScreen) ဆီသို့ တိုက်ရိုက် ပြန်ထွက်သွားမည့် ခလုတ်
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: Text(
                          isPaidUser ? 'Logout' : 'Login',
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  // Stack ရဲ့ သဘာဝအရ နောက်ဆုံးရေးထားသော အရာသည် အပေါ်ဆုံးနှင့် အလယ်ဗဟို (alignment ကြောင့်) တွင် ပေါ်မည်ဖြစ်သည်
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BOOKS',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // ဘာသာရပ်တစ်ခုချင်းစီကို List (စာရင်း) အဖြစ် အောက်သို့ ဆွဲချကြည့်နိုင်ရန် ListView ဖန်တီးခြင်း
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: books.length, // စာအုပ်အရေအတွက်အလိုက် ခလုတ်များ ထုတ်ပေးမည်
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: FullWidthButton(
                      label: book['subject_code']!,
                      isSquare: false,
                      onPressed: () {
                        // ခလုတ်နှိပ်လျှင် အသေးစိတ်ပြသမည့် DetailScreen သို့ သွားမည်
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
// 5. OLD QUESTIONS YEAR SCREEN (မေးခွန်းဟောင်း နှစ်များကို ရွေးချယ်သည့် စာမျက်နှာ)
// ==========================================
class YearsScreen extends StatelessWidget {
  final bool isPaidUser;
  const YearsScreen({super.key, this.isPaidUser = false});

  // ပြသမည့် နှစ်များစာရင်း
  final List<String> years = const ['2023-24', '2024-25', '2025-26'];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header Bar (BooksScreen နည်းတူ အလယ်တည့်တည့်ဖြစ်အောင် Stack ကို သုံးထားသည်)
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
                            icon: const Icon(Icons.arrow_back, color: Color(0xFFFF5A5A), size: 28),
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
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'old questions',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // နှစ်အလိုက် ခလုတ်များကို ပြသပေးခြင်း
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: years.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: FullWidthButton(
                      label: years[index],
                      isSquare: false,
                      onPressed: () {
                        // နှစ်တစ်ခုကို ရွေးချယ်ပါက ထိုနှစ်အတွက် ဘာသာရပ်ရွေးမည့် QuestionsSubjectScreen သို့ သွားမည်
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionsSubjectScreen(
                              year: years[index], // ရွေးချယ်လိုက်သော နှစ်ကို Data အဖြစ် ထည့်ပေးလိုက်သည်
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
// 6. QUESTIONS SUBJECT SCREEN (နှစ်တစ်ခုအတွက် ဘာသာရပ်များကို ပြသမည့် စာမျက်နှာ)
// ==========================================
class QuestionsSubjectScreen extends StatelessWidget {
  final String year; // ရှေ့စာမျက်နှာမှ ပါလာသော နှစ်ကို လက်ခံရန်
  final bool isPaidUser;
  const QuestionsSubjectScreen({super.key, required this.year, this.isPaidUser = false});

  // ဘာသာရပ် အမည်စာရင်းများ
  final List<String> subjects = const [
    'myanmar', 'eng', 'math', 'chem', 'phy', 'bio', 'eco',
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header Bar (Stack ကို သုံး၍ အလယ်တည့်တည့်ချိန်ထားသည်)
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
                            icon: const Icon(Icons.arrow_back, color: Color(0xFFFF5A5A), size: 28),
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
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  // အလယ်ဗဟိုတွင် ရွေးချယ်ခဲ့သော 'နှစ်' နှင့် 'old questions' စာတန်းကို အထက်အောက် ပြသခြင်း
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // စာသားအကျယ်အတိုင်းသာ နေရာယူစေရန်
                      children: [
                        Text(
                          year,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'old questions',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // ဘာသာရပ် ခလုတ်များကို ListView ဖြင့် ပြသခြင်း
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: FullWidthButton(
                      label: subjects[index],
                      isSquare: false,
                      onPressed: () {
                        // ခလုတ်နှိပ်ပါက DetailScreen သို့ (နှစ် + ဘာသာရပ်) အမည် တွဲလျက် ပေးပို့မည်
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
// 7. FINAL CORE DETAIL VIEW (စာအုပ် သို့မဟုတ် မေးခွန်းများကို အသေးစိတ် ဖတ်ရှုရန် နောက်ဆုံးစာမျက်နှာ)
// ==========================================
class DetailScreen extends StatelessWidget {
  final String title; // ခေါင်းစဉ် (ဥပမာ: Grade 12 - Myanmar သို့မဟုတ် 2023-24 - math)
  final String? assetPath; // ဖွင့်ရမည့် PDF (သို့) ပုံ ဖိုင်လမ်းကြောင်း (ရှိလျှင်)

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
            // Header Bar (Stack ကို သုံး၍ အလယ်တည့်တည့်ချိန်ထားသည်)
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
                            icon: const Icon(Icons.arrow_back, color: Color(0xFFFF5A5A), size: 28),
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
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  // အလယ်ဗဟိုတွင် ရွေးချယ်လိုက်သော စာအုပ်/မေးခွန်း ခေါင်းစဉ်ကို ပြသခြင်း
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      // အကယ်၍ '-' ပါပါက အနောက်ပိုင်း (ဘာသာရပ်အမည်) ကိုသာ ယူ၍ ပြသမည့် Logic
                      title.contains('-') ? title.split(' - ')[1] : title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            // လက်ရှိအချိန်တွင် UI အနေဖြင့် မျက်နှာပြင်အလယ်တွင် ခေါင်းစဉ်နှင့် လမ်းကြောင်းကိုသာ ပြသထားသည်
            // (နောင်တွင် ဤနေရာ၌ PDF Viewer သို့မဟုတ် Image Viewer ထည့်သွင်းနိုင်သည်)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    if (assetPath != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'File: $assetPath',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
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