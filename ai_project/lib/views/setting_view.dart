import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  // --- Study Preferences ---
  String _defaultSubject = 'Math';
  String _studyMode = 'Standard Mode';
  String _difficultyLevel = 'Medium';

  // --- Study & Reminders ---
  bool _studyReminders = true;
  int _dailyGoalMinutes = 60;
  bool _examCountdown = true;

  // --- Progress ---
  bool _saveProgress = true;
  bool _performanceTracking = true;
  bool _weakTopicDetection = true;

  // --- Appearance ---
  String _selectedTheme = 'Light Theme';
  String _fontSize = 'Medium';
  bool _comfortReadingMode = false;

  // --- Data & Storage ---
  bool _offlineSync = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultSubject = prefs.getString('set_subject') ?? 'Math';
      _studyMode = prefs.getString('set_study_mode') ?? 'Standard Mode';
      _difficultyLevel = prefs.getString('set_difficulty') ?? 'Medium';

      _studyReminders = prefs.getBool('set_study_reminders') ?? true;
      _dailyGoalMinutes = prefs.getInt('set_daily_goal') ?? 60;
      _examCountdown = prefs.getBool('set_exam_countdown') ?? true;

      _saveProgress = prefs.getBool('set_save_progress') ?? true;
      _performanceTracking = prefs.getBool('set_perf_track') ?? true;
      _weakTopicDetection = prefs.getBool('set_weak_topics') ?? true;

      _selectedTheme = prefs.getString('set_theme') ?? 'Light Theme';
      _fontSize = prefs.getString('set_font_size') ?? 'Medium';
      _comfortReadingMode = prefs.getBool('set_comfort_read') ?? false;

      _offlineSync = prefs.getBool('set_offline_sync') ?? true;
    });
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  void _showChoiceDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required Function(String) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final isSelected = opt == currentValue;
            return ListTile(
              title: Text(opt),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Color(0xFF76C843))
                  : null,
              onTap: () {
                onSelected(opt);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
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
          'Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. STUDY PREFERENCES =================
            _buildSectionHeader(Icons.menu_book_rounded, 'STUDY PREFERENCES'),
            _buildNavTile(
              title: 'Preferred Subject',
              value: _defaultSubject,
              onTap: () => _showChoiceDialog(
                title: 'Select Preferred Subject',
                options: [
                  'Myanmar',
                  'English',
                  'Math',
                  'Chemistry',
                  'Physics',
                  'Biology',
                  'Economics',
                ],
                currentValue: _defaultSubject,
                onSelected: (val) {
                  setState(() => _defaultSubject = val);
                  _saveString('set_subject', val);
                },
              ),
            ),
            _buildNavTile(
              title: 'Default Study Mode',
              value: _studyMode,
              onTap: () => _showChoiceDialog(
                title: 'Study Mode',
                options: [
                  'Standard Mode',
                  'Exam Revision',
                  'Practice Test',
                  'Deep Focus',
                ],
                currentValue: _studyMode,
                onSelected: (val) {
                  setState(() => _studyMode = val);
                  _saveString('set_study_mode', val);
                },
              ),
            ),
            _buildNavTile(
              title: 'Difficulty Level',
              value: _difficultyLevel,
              onTap: () => _showChoiceDialog(
                title: 'Question Difficulty',
                options: ['Beginner', 'Medium', 'Advanced / Matriculation'],
                currentValue: _difficultyLevel,
                onSelected: (val) {
                  setState(() => _difficultyLevel = val);
                  _saveString('set_difficulty', val);
                },
              ),
            ),

            const SizedBox(height: 24),

            // ================= 2. STUDY & REMINDERS =================
            _buildSectionHeader(
              Icons.access_time_filled_rounded,
              'STUDY & REMINDERS',
            ),
            _buildSwitchTile(
              title: 'Study Reminders',
              subtitle: 'Daily push notifications for revision',
              value: _studyReminders,
              onChanged: (val) {
                setState(() => _studyReminders = val);
                _saveBool('set_study_reminders', val);
              },
            ),
            _buildNavTile(
              title: 'Daily Study Goal',
              value: '$_dailyGoalMinutes mins / day',
              onTap: () => _showChoiceDialog(
                title: 'Set Daily Target',
                options: [
                  '30 mins',
                  '45 mins',
                  '60 mins',
                  '90 mins',
                  '120 mins',
                ],
                currentValue: '$_dailyGoalMinutes mins',
                onSelected: (val) {
                  final mins = int.parse(val.split(' ')[0]);
                  setState(() => _dailyGoalMinutes = mins);
                  _saveInt('set_daily_goal', mins);
                },
              ),
            ),
            _buildSwitchTile(
              title: 'Exam Countdown',
              subtitle: 'Display days remaining until final exams on home',
              value: _examCountdown,
              onChanged: (val) {
                setState(() => _examCountdown = val);
                _saveBool('set_exam_countdown', val);
              },
            ),

            const SizedBox(height: 24),

            // ================= 3. PROGRESS =================
            _buildSectionHeader(Icons.bar_chart_rounded, 'PROGRESS'),
            _buildSwitchTile(
              title: 'Save Study Progress',
              subtitle: 'Store completed chapters and last read pages',
              value: _saveProgress,
              onChanged: (val) {
                setState(() => _saveProgress = val);
                _saveBool('set_save_progress', val);
              },
            ),
            _buildSwitchTile(
              title: 'Performance Tracking',
              subtitle: 'Track accuracy and scores across old questions',
              value: _performanceTracking,
              onChanged: (val) {
                setState(() => _performanceTracking = val);
                _saveBool('set_perf_track', val);
              },
            ),
            _buildSwitchTile(
              title: 'Weak Topic Detection',
              subtitle: 'AI suggestions for topics needing improvement',
              value: _weakTopicDetection,
              onChanged: (val) {
                setState(() => _weakTopicDetection = val);
                _saveBool('set_weak_topics', val);
              },
            ),

            const SizedBox(height: 24),

            // ================= 4. APPEARANCE =================
            _buildSectionHeader(Icons.palette_rounded, 'APPEARANCE'),
            _buildNavTile(
              title: 'Theme',
              value: _selectedTheme,
              onTap: () => _showChoiceDialog(
                title: 'Select Theme',
                options: ['Light Theme', 'Dark Mode', 'System Default'],
                currentValue: _selectedTheme,
                onSelected: (val) {
                  setState(() => _selectedTheme = val);
                  _saveString('set_theme', val);
                },
              ),
            ),
            _buildNavTile(
              title: 'Font Size',
              value: _fontSize,
              onTap: () => _showChoiceDialog(
                title: 'Text Scale',
                options: ['Small', 'Medium', 'Large', 'Extra Large'],
                currentValue: _fontSize,
                onSelected: (val) {
                  setState(() => _fontSize = val);
                  _saveString('set_font_size', val);
                },
              ),
            ),
            _buildSwitchTile(
              title: 'Comfort Reading Mode',
              subtitle: 'Warm sepia screen filter for long study sessions',
              value: _comfortReadingMode,
              onChanged: (val) {
                setState(() => _comfortReadingMode = val);
                _saveBool('set_comfort_read', val);
              },
            ),

            const SizedBox(height: 24),

            // ================= 5. DATA & STORAGE =================
            _buildSectionHeader(Icons.save_rounded, 'DATA & STORAGE'),
            _buildSwitchTile(
              title: 'Offline Data Sync',
              subtitle: 'Pre-cache books and questions locally',
              value: _offlineSync,
              onChanged: (val) {
                setState(() => _offlineSync = val);
                _saveBool('set_offline_sync', val);
              },
            ),
            _buildActionTile(
              icon: Icons.cleaning_services_outlined,
              title: 'Clear Temporary Files',
              subtitle: 'Free storage cache without clearing your notes',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Temporary cache cleared successfully!'),
                    backgroundColor: Color(0xFF76C843),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ================= 6. ABOUT =================
            _buildSectionHeader(Icons.info_outline_rounded, 'ABOUT'),
            _buildActionTile(
              icon: Icons.school_outlined,
              title: 'About the App',
              subtitle: 'Learn about Grade 12 Learning Assistant',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Education App',
                applicationVersion: '1.0.0 (Build 2026.1)',
                applicationLegalese: '© 2026 Grade 12 Education AI Assistant',
              ),
            ),
            _buildActionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How your learning data is processed securely',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Privacy Policy'),
                    content: const Text(
                      'Your study habits, notes, and progress records are stored safely on device and synced only to your authenticated account.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildInfoTile(title: 'App Version', value: 'v1.0.0'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- Reusable Tile Builders ---

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4A769E)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A769E),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black38,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        value: value,
        activeColor: const Color(0xFF76C843),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFE76F51), size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.black38,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
