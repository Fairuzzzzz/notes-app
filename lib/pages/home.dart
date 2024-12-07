import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notesapp/auth/auth_service.dart';
import 'package:notesapp/pages/note_editor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  final String userId;
  const Home({required this.userId, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final authService = AuthService();
  String username = '';
  List<Map<String, dynamic>> notes = [];
  final TextEditingController _serachController = TextEditingController();
  List<Map<String, dynamic>> filteredNotes = [];
  bool isSearching = false;

  void logout() async {
    await authService.signOut();
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
    loadNotes();
    filteredNotes = notes;
    _serachController.addListener(() {
      filterNotes(_serachController.text);
    });
  }

  @override
  void dispose() {
    _serachController.dispose();
    super.dispose();
  }

  Future<void> createNewNote() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      String workspaceId;

      try {
        final workspaceResponse = await _supabase
            .from('workspaces')
            .select('id')
            .eq('workspace_name', 'Personal')
            .eq('created_by', userId)
            .single();

        workspaceId = workspaceResponse['id'];
      } catch (e) {
        final newWorkspace = await _supabase.from('workspaces').insert({
          'workspace_name': 'Personal',
          'created_by': userId,
          'updated_by': userId
        }).select();
        workspaceId = newWorkspace[0]['id'];
      }

      final response = await _supabase.from('notes').insert({
        'title': 'New Note',
        'content': '',
        'workspace_id': workspaceId,
        'category': '',
        'created_by': userId,
        'updated_by': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select();

      if (mounted && response.isNotEmpty) {
        setState(() {
          notes.add(response.first);
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NoteEditor(noteId: response.first['id'])));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error creating note: $e')));
      }
    }
  }

  Future<void> _loadUsername() async {
    try {
      final name = await authService.getCurrentUsername();
      if (mounted) {
        setState(() {
          username = name!;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          username = 'User';
        });
      }
    }
  }

  Future<void> loadNotes() async {
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          notes = List<Map<String, dynamic>>.from(response);
          filteredNotes = notes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading notes: $e')));
      }
    }
  }

  void filterNotes(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredNotes = notes;
        isSearching = false;
      });
    } else {
      setState(() {
        filteredNotes = notes
            .where((note) => note['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        isSearching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 24, top: 10, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
                opacity: isSearching ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  height: isSearching ? 40 : 0,
                  child: isSearching
                      ? TextField(
                          controller: _serachController,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Poppins'),
                          decoration: InputDecoration(
                              hintText: 'Search notes...',
                              hintStyle: const TextStyle(
                                  color: Colors.white54, fontFamily: 'Poppins'),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.white)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.white)),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12)),
                        )
                      : null,
                )),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Notes",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.w300),
                ),
                GestureDetector(
                  onTap: createNewNote,
                  child: Container(
                    height: 50,
                    width: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: SvgPicture.asset(
                      'assets/icons/Plus.svg',
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              height: 30,
              width: 120,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6), color: Colors.white),
              child: Row(
                children: [
                  const Text(
                    "Personal",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  SvgPicture.asset(
                    'assets/icons/ChevronDown.svg',
                    height: 18,
                    width: 18,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Expanded(
                child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NoteEditor(noteId: note['id'])));
                    if (result == true ||
                        result == 'updated' ||
                        result == 'created') {
                      loadNotes();
                    }
                  },
                  child: Container(
                    height: 60,
                    width: 120,
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white),
                    child: Row(
                      children: [
                        Text(
                          note['title'] ?? 'New Note',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Welcome back $username",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSearching = !isSearching;
                        if (!isSearching) {
                          _serachController.clear();
                          filteredNotes = notes;
                        }
                      });
                    },
                    child: SvgPicture.asset(
                      'assets/icons/Search.svg',
                      height: 20,
                      width: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/icons/Bell.svg',
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: logout,
                    child: SvgPicture.asset(
                      'assets/icons/Logout.svg',
                      height: 20,
                      width: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
