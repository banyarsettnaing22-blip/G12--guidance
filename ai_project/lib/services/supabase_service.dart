import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // လက်ရှိ User သည် Login ဝင်ထားခြင်း ရှိ/မရှိ စစ်ဆေးခြင်း
  bool get isLoggedIn => supabase.auth.currentUser != null;

  // Paid User Login ဝင်ခြင်းနှင့် Paid Status စစ်ဆေးခြင်း
  Future<bool> loginPaidUser(String email, String password) async {
    try {
      // ၁။ Supabase Auth ဖြင့် Login စစ်ဆေးခြင်း
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) return false;

      // ၂။ Profiles table ထဲတွင် Paid User စစ်စစ် ဟုတ်/မဟုတ် စစ်ဆေးခြင်း
      final data = await supabase
          .from('profiles')
          .select('is_paid')
          .eq('email', email)
          .single();

      return data['is_paid'] as bool? ?? false;
    } catch (e) {
      print("Login / Auth Error: $e");
      return false;
    }
  }

  // Logout ပြုလုပ်ခြင်း
  Future<void> logoutUser() async {
    await supabase.auth.signOut();
  }
}