import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'books_screen.dart';

// User Login ဝင်ရောက်ရန် Form ပါဝင်သော စာမျက်နှာ
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Input fields များမှ စာသားများကို ဖမ်းယူရန် Controller များ
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Supabase Database နှင့် ဆက်သွယ်ရန် Service Object
  final SupabaseService _supabaseService = SupabaseService();
  
  // Login လုပ်နေစဉ် Loading ပြသရန် အခြေအနေပြ Variable
  bool _isLoading = false;

  // Login စစ်ဆေးခြင်း လုပ်ဆောင်ပေးသည့် Method
  void _handleLogin() async {
    setState(() => _isLoading = true); // Loading စတင်ပြသခြင်း
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Supabase တွင် User အကောင့်နှင့် Paid Status ကို စစ်ဆေးခြင်း
    final isPaid = await _supabaseService.loginPaidUser(email, password);
    
    setState(() => _isLoading = false); // Loading ပိတ်ခြင်း

    if (isPaid && mounted) {
      // Login အောင်မြင်ပါက BooksScreen သို့ လုံးဝ ကူးပြောင်းခြင်း (Back ပြန်ခေါ်မရစေရန် pushReplacement သုံးသည်)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BooksScreen()),
      );
    } else if (mounted) {
      // Login မအောင်မြင်ပါက အသိပေးစာ ပြသခြင်း
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed or not a paid account!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ထိပ်ဆုံးတွင် Back Arrow Button ပါဝင်သော AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF5A5A)),
          onPressed: () {
            // ယခင်ရောက်ခဲ့သော LandingScreen သို့ ပြန်သွားရန် Method
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // အီးမေးလ် ရိုက်ထည့်ရန် အကွက်
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Username / Email:'),
            ),
            const SizedBox(height: 16),
            
            // လျှို့ဝှက်နံပါတ် ရိုက်ထည့်ရန် အကွက်
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password:'),
            ),
            const SizedBox(height: 30),
            
            // Login စတင် အလုပ်လုပ်မည့် ခလုတ်
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5A5A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}