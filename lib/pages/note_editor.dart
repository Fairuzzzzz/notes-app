import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteEditor extends StatefulWidget {
  final String noteId;
  const NoteEditor({required this.noteId, super.key});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
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
      await Supabase.instance.client
          .from('notes')
          .update({'content': _contentController.text}).eq('id', widget.noteId);
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
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _contentController,
          style: const TextStyle(color: Colors.white),
          maxLines: null,
          decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Start Writing...',
              hintStyle: TextStyle(color: Colors.white)),
          onChanged: (_) => _saveNote,
        ),
      ),
    );
  }
}
