import 'package:flutter/material.dart';
import '../data/offline_data.dart';
import 'login_screen.dart';

// စာအုပ်ဘာသာရပ်များ စာရင်းကို ပြသပေးသည့် စာမျက်နှာ
class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Offline ဒေတာစာရင်းထဲမှ စာအုပ်ဘာသာရပ်များကို ယူဆောင်ခြင်း
    final books = OfflineData.offlineBooks;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // ဘယ်ဘက်ထိပ်တွင် ယခင်စာမျက်နှာသို့ ပြန်သွားနိုင်မည့် Back Button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF5A5A)),
          onPressed: () {
            // ယခင်ရောက်ခဲ့သော နေရာသို့ ပြန်လည်ရောက်ရှိစေခြင်း
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        // ခေါင်းစဉ် (BOOKS Badge)
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5A5A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('BOOKS', style: TextStyle(color: Colors.white, fontSize: 14)),
        ),
        // ညာဘက်ထိပ်တွင် Login Screen သို့ သွားမည့် Button
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Login', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
      // ဘာသာရပ် ခလုတ်များကို စာရင်းလိုက် ဆွဲထုတ်ပေးသော ListView
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5A5A),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // သက်ဆိုင်ရာ စာအုပ်ကို နှိပ်သည့်အခါ ဖွင့်ပေးမည့် Event
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening: ${book['display_name']}')),
                );
              },
              child: Text(
                book['subject_code']!,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          );
        },
      ),
    );
  }
}