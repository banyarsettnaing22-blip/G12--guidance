import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notes_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends State<AskAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _textbookContent = '';

  final String _openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  // ဘာသာရပ်အလိုက် Quick Chips စာရင်း (English အပါအဝင် ၆ ခု)
  final List<Map<String, String>> _quickPromptList = [
    {
      'label': '📐 Maths: Calculus & Formulas',
      'prompt':
          'Calculus အခန်းမှ Differentiation နှင့် Integration ဆိုင်ရာ သဘောတရားနှင့် အဓိက formulas များကို ရှင်းပြပါ',
    },
    {
      'label': '⚡ Physics: Rotational & Fluid Dynamics',
      'prompt':
          'Rotational Motion နှင့် Fluid Dynamics အခန်းမှ အဓိက formulas များနှင့် သဘောတရားများကို ရှင်းပြပါ',
    },
    {
      'label': '🧪 Chemistry: Bonding & Kinetics',
      'prompt':
          'Chemical Bonding နှင့် Chemical Kinetics အခန်းမှ အဓိက အချက်များနှင့် formulas များကို ရှင်းပြပါ',
    },
    {
      'label': '🧬 Biology: DNA & RNA Structure',
      'prompt': 'RNA Structure အကြောင်းရှင်းပြပါ',
    },
    {
      'label': '📊 Economics: Production & Costs',
      'prompt':
          'Theory of Production နှင့် Costs of Production အကြောင်း အဓိက သဘောတရားများကို ရှင်းပြပါ',
    },
    {
      'label': '📝 English: Grammar & Vocabulary',
      'prompt':
          'Grade 12 English သင်ရိုးပါ Conditionals, Relative Clauses နှင့် Idioms ဆိုင်ရာ အဓိက Grammar မှတ်စုများကို ရှင်းပြပါ',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTextbookData();
  }

  Future<void> _loadTextbookData() async {
    try {
      final data = await rootBundle.loadString(
        'assets/texts/project g12 guidance.txt',
      );
      setState(() {
        _textbookContent = data;
      });
    } catch (e) {
      debugPrint('Textbook load error: $e');
    }
  }

  Future<void> _sendMessage({String? customPrompt}) async {
    final text = customPrompt ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (_openAiApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key not found in .env file!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    if (customPrompt == null) {
      _controller.clear();
    }
    _scrollToBottom();

    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      final systemPrompt = '''
You are a Grade 12 educational tutor for Myanmar students.

Guidelines:
1. First, locate the relevant content from the TEXTBOOK CONTENT.
2. Structure your response into two distinct, well-formatted sections:

### 📖 Textbook Reference
Wrap the ENTIRE English textbook quote inside a markdown blockquote. Put `> ` at the start of EVERY single quoted line so that the entire English reference stays together in the quote card:
> **[Topic Name]**
> * [English definition or key formula]
> * [English key point]

### 💡 မြန်မာလို ရှင်းလင်းချက်
Provide a clear, natural explanation and breakdown in Myanmar language (Burmese) right below the quote without over-exaggeration.

3. STRICT RULES FOR MATHEMATICS, PHYSICS, AND CHEMISTRY FORMULAS:
   - DO NOT use LaTeX syntax (NEVER write \\frac, \\omega, \\theta, \\rho, \\alpha, \\text, etc.).
   - ALWAYS use proper UNICODE SUPERSCRIPTS and SUBSCRIPTS for powers, indices, and chemical formulas:
     * Chemistry Subscripts: Write H₂O, CO₂, H₂SO₄, O₂, N₂, CH₄ (DO NOT write H2O, CO2, H_2O).
     * Ions/Charges: Write Ca²⁺, Na⁺, Cl⁻, SO₄²⁻, Fe³⁺.
     * Math & Physics Powers (Superscripts): Write x², x³, xⁿ, xⁿ⁺¹, t², v², r² (DO NOT write x^2, x^n, t^2).
     * Physics/Math Subscripts: Write ω₀, v₀, a_c, K_w, P₁, V₁ (or standard unicode: ω₀, K_w).
     * Fractions & Calculus: Write `d/dx (xⁿ) = n·xⁿ⁻¹`, `∫ xⁿ dx = (xⁿ⁺¹)/(n+1) + C`, `p + ½ρv² + ρgh = constant`.
   - Always enclose formulas and equations in backticks `` `...` `` so they display as highlighted formula badges.

4. AT THE VERY END OF EVERY RESPONSE (MANDATORY):
   - Provide a direct markdown search link to YouTube for the topic.
   - Do NOT include 'Grade 12' or 'Myanmar' in the link text or query.
   - Format exactly as:
     ---
     [Youtube video: (Topic Name) ကြည့်ရှုရန်](https://www.youtube.com/results?search_query=Topic+Name)
     (Replace 'Topic Name' with the concise English topic name, and join query words with '+').

5. Only rely on external knowledge if the concept is completely absent from the textbook text.

--- TEXTBOOK CONTENT ---
$_textbookContent
------------------------
''';

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ..._messages.map(
              (m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              },
            ),
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiResponse =
            data['choices']?[0]?['message']?['content'] ??
            'No response received.';

        setState(() {
          _messages.add(ChatMessage(text: aiResponse.trim(), isUser: false));
        });
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = errorData['error']?['message'] ?? response.body;

        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Error ${response.statusCode}: $errorMessage',
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Connection Error: $e', isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _launchUrlLink(String urlString) async {
    final url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('လင့်ခ်ကို ဖွင့်၍ မရနိုင်ပါ')),
        );
      }
    }
  }

  Future<void> _openYouTubeSearch(String query) async {
    final cleanLine = query
        .split('\n')
        .first
        .replaceAll(RegExp(r'[#*>]'), '')
        .trim();
    final cleanQuery = Uri.encodeComponent(cleanLine);
    final url = 'https://www.youtube.com/results?search_query=$cleanQuery';
    await _launchUrlLink(url);
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('အဖြေကို Copy ကူးယူပြီးပါပြီ'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✨ Auto-extract Topic + Clean Content before Save
  Future<void> _saveToMyNotes(String content) async {
    String defaultTopic = '';

    // 1. YouTube link အမည်မှ topic ကို ရှာယူခြင်း
    final ytMatch = RegExp(
      r'Youtube video:\s*([^\(\)]+?)\s*(?:ကြည့်ရှုရန်|\))',
      caseSensitive: false,
    ).firstMatch(content);
    if (ytMatch != null) {
      defaultTopic =
          ytMatch.group(1)?.replaceAll(RegExp(r'[#*>`\[\]]'), '').trim() ?? '';
    }

    // 2. Blockquote ထဲက [TOPIC ...] ကို ရှာဖွေခြင်း
    if (defaultTopic.isEmpty) {
      final topicMatch = RegExp(
        r'\[?(TOPIC[^\]\n]+)\]?',
        caseSensitive: false,
      ).firstMatch(content);
      if (topicMatch != null) {
        defaultTopic =
            topicMatch.group(1)?.replaceAll(RegExp(r'[#*>`\[\]]'), '').trim() ??
            '';
      }
    }

    // 3. Fallback: အထက်ပါနှစ်ခုလုံး မတွေ့ပါက ပထမဆုံး စာကြောင်းကို ယူခြင်း
    if (defaultTopic.isEmpty) {
      defaultTopic = content
          .split('\n')
          .firstWhere(
            (line) =>
                line.trim().isNotEmpty &&
                !line.startsWith('---') &&
                !line.startsWith('#'),
            orElse: () => 'Grade 12 Study Note',
          )
          .replaceAll(RegExp(r'[#*>`\[\]]'), '')
          .trim();
    }

    final titleController = TextEditingController(text: defaultTopic);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bookmark_add, color: Color(0xFF2EB5FA)),
            SizedBox(width: 8),
            Text(
              'Save to My Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Note Title:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: defaultTopic.isNotEmpty
                    ? defaultTopic
                    : 'Enter note title...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EB5FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final userEntered = titleController.text.trim();
              final finalTitle =
                  userEntered.isNotEmpty ? userEntered : defaultTopic;

              // ✨ Storage ထဲ သိမ်းဆည်းချိန်တွင် ###, >, ** များကို clean လုပ်ပြီး * နေရာတွင် • ချက်ချင်းထည့်ခြင်း
              final cleanContent = content
                  .replaceAll(RegExp(r'^###\s*', multiLine: true), '')
                  .replaceAll(RegExp(r'^\>\s*', multiLine: true), '')
                  .replaceAll('**', '')
                  .replaceAll(RegExp(r'^---\s*$', multiLine: true), '')
                  .replaceAll(RegExp(r'^\*\s+', multiLine: true), '• ')
                  .trim();

              try {
                // NotesService သို့ တိုက်ရိုက် addNote ခေါ်ယူသိမ်းဆည်းခြင်း
                await NotesService.addNote(finalTitle, cleanContent);

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"$finalTitle" ကို My Notes ထဲသို့ သိမ်းဆည်းပြီးပါပြီ'),
                      backgroundColor: const Color(0xFF76C843),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final String? raw = prefs.getString('saved_notes');
                  List<dynamic> list = [];
                  if (raw != null && raw.isNotEmpty) {
                    try { list = jsonDecode(raw); } catch (_) {}
                  }
                  list.insert(0, {
                    'title': finalTitle,
                    'content': cleanContent,
                    'date': DateTime.now().toIso8601String(),
                  });
                  await prefs.setString('saved_notes', jsonEncode(list));
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"$finalTitle" ကို My Notes ထဲသို့ သိမ်းဆည်းပြီးပါပြီ'),
                        backgroundColor: const Color(0xFF76C843),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (err) {
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Save error: $err'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask AI', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2EB5FA),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickPromptList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _quickPromptList[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _sendMessage(customPrompt: item['prompt']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item['label']!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF76C843) : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : null,
            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            message.isUser
                ? SelectableText(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  )
                : MarkdownBody(
                    data: message.text,
                    selectable: true,
                    onTapLink: (text, href, title) {
                      if (href != null && href.isNotEmpty) {
                        _launchUrlLink(href);
                      }
                    },
                    styleSheet: MarkdownStyleSheet(
                      blockquote: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF2EB5FA), width: 4),
                        ),
                      ),
                      blockquotePadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      code: const TextStyle(
                        color: Color(0xFF0D47A1),
                        backgroundColor: Color(0xFFE8F0FE),
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      p: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      h1: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      h2: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      h3: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0288D1),
                      ),
                      h4: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      listBullet: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      a: const TextStyle(
                        color: Color(0xFF1976D2),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
            if (!message.isUser) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                    tooltip: 'Copy ယူရန်',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 14),
                    onPressed: () => _copyToClipboard(message.text),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.video_library,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'YouTube တွင် ရှာကြည့်ရန်',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 14),
                    onPressed: () => _openYouTubeSearch(message.text),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark_add_outlined,
                      size: 19,
                      color: Color(0xFF2EB5FA),
                    ),
                    tooltip: 'Save to My Notes',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () => _saveToMyNotes(message.text),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF2EB5FA),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}