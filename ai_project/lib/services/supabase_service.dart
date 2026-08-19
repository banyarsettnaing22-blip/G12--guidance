import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<bool> loginPaidUser(String loginId, String password) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          // "$loginId" များကို Double Quotes "" ဖြင့် အုပ်ပေးရပါမည် 
          // (ဥပမာ- email တွင် @ ပါလာလျှင် Error မတက်စေရန်)
          .or('name.eq."$loginId",email.eq."$loginId"')
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        bool isPaid = response['is_paid'] ?? false;
        if (isPaid) {
          print('Login Success!');
          return true; 
        }
      }
      return false; 
    } catch (e) {
      // Error တက်ခဲ့လျှင် Terminal တွင် ပြပေးမည်
      print('Supabase Login Error: $e'); 
      return false;
    }
  }
}