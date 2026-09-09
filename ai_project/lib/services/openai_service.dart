import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<Map<String, dynamic>> generateComprehensiveQuiz({
    required String subject,
    required String topic,
  }) async {
    String allTextContent = "";
    try {
      allTextContent = await rootBundle.loadString('assets/texts/project g12 guidance.txt');
      debugPrint('Text File Loaded Successfully! Length: ${allTextContent.length} characters');
    } catch (e) {
      throw Exception('Text file not found: $e');
    }

    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API Key is missing.');
    }

    final prompt = '''
You are an expert Grade 12 examination setter for the Myanmar curriculum.
Generate a comprehensive 60-question test based STRICTLY on the reference text below for:
- Subject: "$subject"
- Topic/Chapter: "$topic"

LANGUAGE RULES:
- If Subject is "Myanmar", output all questions, options, answers, and explanations strictly in Burmese script.
- For ALL OTHER subjects (English, Mathematics, Physics, Chemistry, Biology, Economics), output everything strictly in ENGLISH.

QUESTION BREAKDOWN (Total 60 questions):
1. multiple_choice: Exactly 20 questions (each with 4 options, exact correct answer, and explanation).
2. fill_in_the_blank: Exactly 20 questions (use "_____" for the missing term, provide the answer, and explanation).
3. short_answer: Exactly 20 conceptual or short questions (provide question, expected concise answer, and explanation).

CRITICAL CONSTRAINTS:
- Rely ONLY on the reference text below. Do NOT use outside general knowledge trivia.
- Return ONLY valid raw JSON without markdown wrapping (no ```json).

JSON SCHEMA:
{
  "multiple_choice": [
    {
      "question": "Question text?",
      "options": ["A", "B", "C", "D"],
      "correct_answer": "Exact text",
      "explanation": "Context reason"
    }
  ],
  "fill_in_the_blank": [
    {
      "question": "Sentence with _____ blank.",
      "correct_answer": "Missing word",
      "explanation": "Context reason"
    }
  ],
  "short_answer": [
    {
      "question": "Short conceptual question?",
      "correct_answer": "Model answer",
      "explanation": "Key concept"
    }
  ]
}

=== REFERENCE TEXTBOOK DATA ===
$allTextContent
===============================
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': 'You output strictly raw JSON without markdown.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.2,
        'max_tokens': 12000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String content = data['choices'][0]['message']['content'];
      content = content.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(content) as Map<String, dynamic>;
    } else {
      throw Exception('OpenAI API Error: ${response.body}');
    }
  }
}