import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Notification အဖွင့်/အပိတ် မှတ်သားမည့် Variable များ
  bool _generalNotifications = true;
  bool _sound = true;
  bool _vibrate = false;
  bool _appUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // စာမျက်နှာပွင့်တာနဲ့ သိမ်းထားတဲ့ Setting ကို ယူမည်
  }

  // Local Storage မှ Setting များကို ပြန်ခေါ်ခြင်း
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _generalNotifications = prefs.getBool('notif_general') ?? true;
      _sound = prefs.getBool('notif_sound') ?? true;
      _vibrate = prefs.getBool('notif_vibrate') ?? false;
      _appUpdates = prefs.getBool('notif_updates') ?? true;
    });
  }

  // Setting ပြောင်းတိုင်း Local Storage သို့ သိမ်းခြင်း
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Messages & Alerts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: "General Notifications",
              subtitle: "Get alerts for daily news and messages",
              value: _generalNotifications,
              onChanged: (val) {
                setState(() => _generalNotifications = val);
                _saveSetting('notif_general', val);
              },
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: "Sound",
              subtitle: "Play sound for incoming notifications",
              value: _sound,
              onChanged: (val) {
                setState(() => _sound = val);
                _saveSetting('notif_sound', val);
              },
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: "Vibrate",
              subtitle: "Vibrate for incoming notifications",
              value: _vibrate,
              onChanged: (val) {
                setState(() => _vibrate = val);
                _saveSetting('notif_vibrate', val);
              },
            ),
            
            const SizedBox(height: 32),
            const Text(
              "System",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: "App Updates",
              subtitle: "Get notified when a new version is available",
              value: _appUpdates,
              onChanged: (val) {
                setState(() => _appUpdates = val);
                _saveSetting('notif_updates', val);
              },
            ),
          ],
        ),
      ),
    );
  }

  // အဖွင့်/အပိတ် (Switch) ခလုတ်လေးများ တည်ဆောက်ရန် Widget
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        value: value,
        activeColor: const Color(0xFF76C843), // အစိမ်းရောင်
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}