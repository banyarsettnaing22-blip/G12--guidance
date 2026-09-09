// lib/data/offline_data.dart
class OfflineData {
  static const List<Map<String, String>> offlineBooks = [
    {
      'subject_code': 'Myanmar (Special)',
      'display_name': 'G12 Myanmar အထူးထုတ်',
      // သင့်ဆီမှာ g12_myanmar_special.pdf ဖိုင်ရှိမရှိ စစ်ဆေးပါ။ မရှိရင် myanmar.pdf လို့ပဲ ပြောင်းသုံးပါ။
      'asset_path': 'assets/books/g12_myanmar_special.pdf', 
      'file_id': '', 
      'is_offline': 'true',
    },
    {
      'subject_code': 'Myanmar',
      'display_name': 'Myanmar',
      'asset_path': 'assets/books/myanmar.pdf',
      'file_id': '',
      'is_offline': 'true',
    },
    {
      'subject_code': 'English',
      'display_name': 'English',
      'asset_path': 'assets/books/english.pdf',
      'file_id': '',
      'is_offline': 'true',
    },
    {
      'subject_code': 'Mathematics',
      'display_name': 'Mathematics',
      // 's' မပါတဲ့ သင့်ဖိုင်နာမည်အတိုင်း ပြင်ထားပါတယ်
      'asset_path': 'assets/books/mathematic.pdf',
      'file_id': '',
      'is_offline': 'true',
    },
    {
      'subject_code': 'Chemistry',
      'display_name': 'Chemistry',
      'asset_path': 'assets/books/chemistry.pdf',
      'file_id': '',
      'is_offline': 'true',
    },
    {
      'subject_code': 'Physics',
      'display_name': 'Physics',
      'asset_path': 'assets/books/physics.pdf',
      'file_id': '',
      'is_offline': 'true',
    },
    {
      'subject_code': 'Biology',
      'display_name': 'Biology',
      'asset_path': 'assets/books/biology.pdf',
      'file_id': '',
      'is_offline': 'true',
    },
    {
      'subject_code': 'Economics',
      'display_name': 'Economics',
      // 's' မပါတဲ့ သင့်ဖိုင်နာမည်အတိုင်း ပြင်ထားပါတယ်
      'asset_path': 'assets/books/economic.pdf',
      'file_id': '',
      'is_offline': 'true',
    },
  ];
}