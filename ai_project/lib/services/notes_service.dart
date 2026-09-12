import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Note {
  String title;
  String content;
  DateTime date;

  Note({required this.title, required this.content, required this.date});

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'date': date.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date']);
    } catch (_) {
      parsedDate = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
    }
    return Note(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      date: parsedDate,
    );
  }
}

class NotesService {
  static const String _storageKey = 'saved_notes';
  static final List<Note> _memoryCache = [];
  static bool _isLoaded = false;

  // Note များ အားလုံးကို ဆွဲထုတ်ခြင်း
  static Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Web cache reload

    final String? notesJson = prefs.getString(_storageKey);
    if (notesJson != null && notesJson.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(notesJson);
        if (decoded is List) {
          _memoryCache.clear();
          for (var item in decoded) {
            if (item is String) {
              _memoryCache.add(Note.fromJson(jsonDecode(item)));
            } else if (item is Map<String, dynamic>) {
              _memoryCache.add(Note.fromJson(item));
            }
          }
          _isLoaded = true;
          return List.from(_memoryCache);
        }
      } catch (e) {
        debugPrint("Error loading notes: $e");
      }
    }

    if (!_isLoaded) {
      _isLoaded = true;
    }
    return List.from(_memoryCache);
  }

  // Note အသစ် ထည့်သွင်းခြင်း (Ask AI ရော Manual ရော ဒီ function ကိုပဲ သုံးမည်)
  static Future<void> addNote(String title, String content, [DateTime? date]) async {
    final newNote = Note(
      title: title,
      content: content,
      date: date ?? DateTime.now(),
    );

    // Memory cache ထဲ အရင်ထည့်မည် (UI တန်းပြနိုင်ရန်)
    _memoryCache.insert(0, newNote);

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_memoryCache.map((n) => n.toJson()).toList());
    
    // Key အားလုံးကို တစ်ပြိုင်နက် သိမ်းပေးခြင်း
    await prefs.setString(_storageKey, encoded);
    await prefs.setString('notes', encoded);
    await prefs.setString('my_notes_list', encoded);
  }

  // Note ပြင်ဆင်ခြင်း
  static Future<void> updateNote(int index, Note note) async {
    if (index >= 0 && index < _memoryCache.length) {
      _memoryCache[index] = note;
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_memoryCache.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    }
  }

  // Note ဖျက်ခြင်း
  static Future<void> deleteNote(int index) async {
    if (index >= 0 && index < _memoryCache.length) {
      _memoryCache.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_memoryCache.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    }
  }
}