import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteEditor extends StatefulWidget {
  final String noteId;
  const NoteEditor({required this.noteId, super.key});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    try {
      final response = await Supabase.instance.client
          .from('notes')
          .select()
          .eq('id', widget.noteId)
          .single();
      if (mounted) {
        setState(() {
          _titleController.text = response['title'] ?? '';
          _contentController.text = response['content'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading note: $e')));
      }
    }
  }

  Future<void> _saveNote() async {
    try {
      await Supabase.instance.client.from('notes').update({
        'title': _titleController,
        'content': _contentController.text,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', widget.noteId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit note',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Title',
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 24)),
              onChanged: (_) => _saveNote,
            ),
            const Divider(color: Colors.white),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                maxLines: null,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Start Writing...',
                    hintStyle: TextStyle(color: Colors.white)),
                onChanged: (_) => _saveNote,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
