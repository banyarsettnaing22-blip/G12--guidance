import 'dart:io'; // File အသုံးပြုရန်
import 'package:flutter/foundation.dart'; // kIsWeb အသုံးပြုရန်
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Local Storage အတွက်
// main.dart ထဲရှိ BooksScreen, YearsScreen နှင့် LandingScreen တို့ကို လှမ်းခေါ်ရန်
import 'package:ai_project/main.dart'; 
import 'package:ai_project/views/ask_ai_screen.dart'; // Ask AI မျက်နှာပြင်ကို ခေါ်ရန်
import 'note_screen.dart'; // ဖိုင်လမ်းကြောင်း မှန်ကန်အောင် ထည့်ပါ
import 'profile_settings_screen.dart'; // Profile Settings ကို လှမ်းခေါ်ရန်

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  String? _imagePath; // Profile ပုံအတွက် Variable အသစ်

  final Color _primaryGreen = const Color(0xFF76C843);
  final Color _bgBlue = const Color(0xFF2EB5FA);
  final Color _cyanCard = const Color(0xFF67E8F9);

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // စာမျက်နှာပွင့်တာနဲ့ သိမ်းထားတဲ့ပုံကို ခေါ်မည်
  }

  // Local Storage မှ ပုံကို လှမ်းယူမည့် Function
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('profile_image_path');
    });
  }

  // Bottom Navigation Bar အလုပ်လုပ်စေရန်
  void _onItemTapped(int index) async {
    // Profile (တတိယခလုတ် - Index 2) ကို နှိပ်ပါက Settings Page သို့ သွားမည်
    if (index == 2) {
      // Navigator ကို await ဖြင့်စောင့်ပြီး ပြန်ထွက်လာပါက ပုံကို အသစ်ပြန်ခေါ်မည် (Refresh)
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
      );
      _loadProfileImage(); 
      return; // အောက်ရှိ _selectedIndex ပြောင်းလဲခြင်းကို မလုပ်ဘဲ ရပ်လိုက်မည်
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Top Green Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // --- Profile Image နေရာကို ပြင်ဆင်ထားသည် ---
                      Container(
                        width: 56, // CircleAvatar(radius: 28) နှင့် အရွယ်အစားတူညီသည်
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: _imagePath != null
                            ? ClipOval(
                                child: kIsWeb
                                    ? Image.network(_imagePath!, fit: BoxFit.cover)
                                    : Image.file(File(_imagePath!), fit: BoxFit.cover),
                              )
                            : const Icon(Icons.person, size: 36, color: Colors.grey),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Premium User', // နာမည်ကို လိုအပ်သလို ပြင်ဆင်နိုင်ပါသည်
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF7E57C2),
                          size: 28,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    // Grid Menu Items
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: [
                        _buildGridCard(
                          icon: Icons.menu_book, 
                          label: 'BOOKS',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BooksScreen(isPaidUser: true)),
                            );
                          }
                        ),
                        _buildGridCard(
                          icon: Icons.quiz_outlined,
                          label: 'Old Questions',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const YearsScreen(isPaidUser: true)),
                            );
                          }
                        ),
                        _buildGridCard(
                          icon: Icons.ondemand_video,
                          label: 'videos',
                          onTap: () {}, // နောက်မှ ထပ်ဖြည့်ရန်
                        ),
                        _buildGridCard(
                          icon: Icons.lightbulb_outline,
                          label: 'Quiz',
                          onTap: () {}, // နောက်မှ ထပ်ဖြည့်ရန်
                        ),
                        _buildGridCard(
                          icon: Icons.psychology_outlined,
                          label: 'Ask AI',
                          onTap: () {
                            // ယခုခလုတ်ကို နှိပ်ပါက Ask AI စာမျက်နှာသို့ သွားမည်ဖြစ်သည်
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AskAIScreen()),
                            );
                          },
                        ),
                        _buildGridCard(
                          icon: Icons.edit_note, 
                          label: 'Note',
                          onTap: () {
                            // Note ခလုတ်ကို နှိပ်ပါက Note စာမျက်နှာသို့ သွားမည်
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NoteScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Wide Action Buttons
                    _buildWideButton(title: 'အမှတ်ပေးစည်းမျဉ်း', onTap: (){}),
                    const SizedBox(height: 16),
                    _buildWideButton(title: 'Sample Questions', onTap: (){}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _primaryGreen,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped, 
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile', // ယခု ဤနေရာကို နှိပ်ပါက Settings စာမျက်နှာကို ခေါ်မည်
            ),
          ],
        ),
      ),
    );
  }

  // Grid Card တည်ဆောက်ရန်
  Widget _buildGridCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 38, color: const Color(0xFF2EB5FA)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wide Button တည်ဆောက်ရန်
  Widget _buildWideButton({required String title, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _cyanCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26A69A), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}