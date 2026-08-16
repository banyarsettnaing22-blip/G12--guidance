import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'books_screen.dart';

// ပထမဆုံး စတင်မြင်တွေ့ရမည့် ပင်မစာမျက်နှာ (Landing Page)
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ပုံကို ပြသပေးခြင်း (ပုံရှာမတွေ့ပါက ကျောင်းအိုင်ကွန် အစားထိုးပြသမည်)
              Image.asset(
                'assets/logo.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school,
                  size: 100,
                  color: Color(0xFFFF5A5A),
                ),
              ),
              const SizedBox(height: 60),

              // ၁။ Log In စာမျက်နှာသို့ သွားမည့် ခလုတ်
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5A5A),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // Navigator.push ကို သုံးထားသောကြောင့် နောက်စာမျက်နှာတွင် Back ခလုတ် ပြန်နှိပ်၍ ရပါမည်
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // ၂။ Guest (စာအုပ်များ ကြည့်ရှုမည့်) စာမျက်နှာသို့ သွားမည့် ခလုတ်
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5A5A),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // BooksScreen သို့ သွားရောက်ခြင်း (Back ခလုတ် ပြန်နှိပ်၍ ရပါမည်)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BooksScreen()),
                    );
                  },
                  child: const Text('Guest', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}