import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        'title': _titleController.text,
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

  Future<void> _clearNote() async {
    setState(() {
      _titleController.text = '';
      _contentController.text = '';
    });
  }

  Future<void> _deleteNote() async {
    final shouldDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                "Delete the note?",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              content: const Text(
                "This action cannot be undone.",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Cancle',
                      style:
                          TextStyle(fontFamily: 'Poppins', color: Colors.black),
                    )),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Delete',
                      style:
                          TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                    ))
              ],
            ));
    if (shouldDelete != true) return;

    try {
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', widget.noteId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted successfully')));
      }

      // Return to home
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error delete note: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'updated');
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Edit note',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _deleteNote,
                    child: SvgPicture.asset(
                      'assets/icons/Trash.svg',
                      height: 20,
                      width: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            )
          ],
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
                        color: Colors.white24,
                        fontFamily: 'Poppins',
                        fontSize: 24)),
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Poppins'),
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Start Writing...',
                      hintStyle: TextStyle(color: Colors.white24)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: _clearNote,
                          child: const Text(
                            "Clear Note",
                            style: TextStyle(
                                color: Colors.black, fontFamily: 'Poppins'),
                          )),
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _saveNote();
                          const snackBar = SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content: Text(
                                'Your Data is Saved',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
