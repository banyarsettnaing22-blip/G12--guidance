import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notes_service.dart';

// Content ထဲမှ Markdown သင်္ကေတများဖယ်ရှားပြီး * ကို • သို့ ပြောင်းပေးသည့် global helper function
String cleanNoteRawContent(String raw) {
  return raw
      .replaceAll(RegExp(r'^###\s*', multiLine: true), '')
      .replaceAll(RegExp(r'^\>\s*', multiLine: true), '')
      .replaceAll('**', '')
      .replaceAll(RegExp(r'^---\s*$', multiLine: true), '')
      .replaceAll(RegExp(r'^\*\s+', multiLine: true), '• ')
      .trim();
}

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final data = await NotesService.getNotes();
    if (mounted) {
      setState(() {
        _notes = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditor([Note? existingNote, int? index]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: existingNote),
      ),
    );

    if (result != null && result is Note) {
      if (index != null) {
        await NotesService.updateNote(index, result);
      } else {
        await NotesService.addNote(result.title, result.content, result.date);
      }
      await _fetchNotes();
    }
  }

  Future<void> _deleteNote(int index) async {
    await NotesService.deleteNote(index);
    await _fetchNotes();
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteNote(index);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2EB5FA),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return _buildNoteCard(note, index);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF76C843),
        onPressed: () => _navigateToEditor(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to capture your ideas.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToEditor(note, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.title.isNotEmpty)
                        Text(
                          note.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (note.title.isNotEmpty) const SizedBox(height: 6),
                      // ✨ Card ပေါ်တွင်လည်း clean လုပ်ထားသော စာသားကို တိုက်ရိုက် ပြသပေးခြင်း
                      Text(
                        note.content.isEmpty
                            ? "No additional text"
                            : cleanNoteRawContent(note.content),
                        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(note.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                  tooltip: 'Delete Note',
                  onPressed: () => _confirmDelete(index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Note Editor Screen ---
class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    
    final cleaned = cleanNoteRawContent(widget.note?.content ?? '');
    _contentController = TextEditingController(text: cleaned);

    _isEditing = (widget.note == null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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

  void _saveAndPop() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty || content.isNotEmpty) {
      final newNote = Note(
        title: title,
        content: content,
        date: widget.note?.date ?? DateTime.now(),
      );
      Navigator.pop(context, newNote);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveAndPop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          actions: [
            if (widget.note != null)
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.visibility_outlined : Icons.edit_outlined,
                  color: const Color(0xFF2EB5FA),
                  size: 24,
                ),
                tooltip: _isEditing ? 'View Mode' : 'Edit Text',
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF76C843), size: 28),
              onPressed: _saveAndPop,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.black26, fontSize: 26, fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 10),
                Expanded(
                  child: _isEditing
                      ? TextField(
                          controller: _contentController,
                          autofocus: widget.note == null,
                          style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: 'Type your note here...',
                            hintStyle: TextStyle(color: Colors.black26, fontSize: 16),
                            border: InputBorder.none,
                          ),
                        )
                      : SingleChildScrollView(
                          child: _buildFormattedContentView(_contentController.text),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Markdown symbols ရှင်းထုတ်ထားပြီး Subtitles (Little Bold)၊ Bullet Points (•) နှင့် Clickable Blue Links ပြသမည့် Widget
  Widget _buildFormattedContentView(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];
    final ytRegex = RegExp(r'\[(.*?)\]\((https?:\/\/.*?)\)');

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // 1. YouTube Link ကို အပြာရောင်ဖြင့် နှိပ်နိုင်အောင် ပြုလုပ်ခြင်း
      if (ytRegex.hasMatch(line)) {
        final match = ytRegex.firstMatch(line)!;
        final linkText = match.group(1) ?? 'YouTube Video';
        final linkUrl = match.group(2) ?? '';

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () => _launchUrlLink(linkUrl),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.video_library, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      linkText,
                      style: const TextStyle(
                        color: Color(0xFF1976D2), // Link အပြာရောင်
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      // 2. Subtitles များကို Little Bold ပုံစံဖော်ခြင်း
      else if (line.contains('Textbook Reference') ||
               line.contains('မြန်မာလို ရှင်းလင်းချက်') ||
               line.startsWith('TOPIC')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w600, // Little bold
                color: Color(0xFF0288D1),
                height: 1.4,
              ),
            ),
          ),
        );
      }
      // 3. Bullet Point (•) နှင့် သာမန်စာကြောင်းများ
      else {
        String displayLine = line;
        if (displayLine.startsWith('* ')) {
          displayLine = displayLine.replaceFirst('* ', '• ');
        }
        final bool isBullet = displayLine.startsWith('• ');

        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              left: isBullet ? 12 : 0,
              top: 3,
              bottom: 3,
            ),
            child: Text(
              displayLine,
              style: const TextStyle(
                fontSize: 15.5,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}