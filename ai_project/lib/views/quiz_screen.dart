import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _topicController = TextEditingController();
  late TabController _tabController;

  String _selectedSubject = 'Physics';
  final List<String> _subjects = [
    'Myanmar', 'English', 'Mathematics', 'Chemistry', 'Physics', 'Biology', 'Economics'
  ];

  bool _isLoading = false;
  Map<String, dynamic>? _quizData;
  final Map<int, String> _mcqAnswers = {};
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _fetchQuiz() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic or chapter.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _quizData = null;
      _mcqAnswers.clear();
      _isSubmitted = false;
    });

    try {
      final quiz = await _openAIService.generateComprehensiveQuiz(
        subject: _selectedSubject,
        topic: _topicController.text.trim(),
      );
      setState(() {
        _quizData = quiz;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  int _calculateScore() {
    if (_quizData == null || _quizData!['multiple_choice'] == null) return 0;
    final mcqs = _quizData!['multiple_choice'] as List;
    int score = 0;
    for (int i = 0; i < mcqs.length; i++) {
      if (_mcqAnswers[i] == mcqs[i]['correct_answer']) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade 12 Comprehensive Quiz', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A769E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Controls Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                      items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _selectedSubject = val!),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Topic / Chapter',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87CE52),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      onPressed: _isLoading ? null : _fetchQuiz,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Generate 60 Questions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tab View Area
            if (_quizData != null) ...[
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF4A769E),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF4A769E),
                tabs: const [
                  Tab(text: 'MCQ (20)'),
                  Tab(text: 'Blanks (20)'),
                  Tab(text: 'Short Q&A (20)'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMCQSection(),
                    _buildSimpleListSection(_quizData!['fill_in_the_blank'] as List? ?? []),
                    _buildSimpleListSection(_quizData!['short_answer'] as List? ?? []),
                  ],
                ),
              ),
            ] else if (!_isLoading)
              const Expanded(
                child: Center(
                  child: Text('Select Subject & Topic to generate quiz', style: TextStyle(color: Colors.grey)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMCQSection() {
    final List list = _quizData!['multiple_choice'] as List? ?? [];
    return ListView.builder(
      itemCount: list.length + 1,
      itemBuilder: (context, index) {
        if (index == list.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _isSubmitted
                ? Center(
                    child: Text(
                      'MCQ Score: ${_calculateScore()} / ${list.length}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A769E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => setState(() => _isSubmitted = true),
                    child: const Text('Submit MCQ Answers', style: TextStyle(color: Colors.white)),
                  ),
          );
        }

        final q = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. ${q['question']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate((q['options'] as List).length, (optIdx) {
                  final option = q['options'][optIdx];
                  Color tileColor = Colors.transparent;
                  if (_isSubmitted) {
                    if (option == q['correct_answer']) {
                      tileColor = Colors.green.withValues(alpha: 0.2);
                    } else if (_mcqAnswers[index] == option) {
                      tileColor = Colors.red.withValues(alpha: 0.2);
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Material(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(8),
                      child: RadioListTile<String>(
                        value: option,
                        groupValue: _mcqAnswers[index],
                        title: Text(option),
                        onChanged: _isSubmitted ? null : (val) => setState(() => _mcqAnswers[index] = val!),
                      ),
                    ),
                  );
                }),
                if (_isSubmitted)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text('💡 ${q['explanation']}', style: const TextStyle(color: Colors.blueGrey)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleListSection(List list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text('${index + 1}. ${item['question']}', style: const TextStyle(fontWeight: FontWeight.w600)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Answer: ${item['correct_answer']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 6),
                    Text('Explanation: ${item['explanation']}', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}