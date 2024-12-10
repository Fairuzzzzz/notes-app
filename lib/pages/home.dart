import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notesapp/auth/auth_service.dart';
import 'package:notesapp/pages/note_editor.dart';
import 'package:path/path.dart';
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
  bool isLoading = true;
  String selectedWorkspace = 'Personal';
  List<Map<String, dynamic>> workspaces = [];

  void logout() async {
    await authService.signOut();
  }

  @override
  void initState() {
    super.initState();
    _serachController.addListener(() {
      filterNotes(_serachController.text);
    });
  }

  @override
  void dispose() {
    _serachController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      await _loadUsername();
      await loadWorkspaces();
      await loadNotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext)
            .showSnackBar(SnackBar(content: Text('Error initializing: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> createNewNote() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final workspace = workspaces
          .firstWhere((w) => w['workspace_name'] == selectedWorkspace);

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
        'workspace_id': workspace['id'],
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

        final BuildContext currentContext = this.context;

        Navigator.push(
            currentContext,
            MaterialPageRoute(
                builder: (context) =>
                    NoteEditor(noteId: response.first['id'])));
      }
    } catch (e) {
      if (mounted) {
        final BuildContext currentContext = this.context;
        ScaffoldMessenger.of(currentContext)
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
      if (workspaces.isEmpty) return;

      final workspace = workspaces.firstWhere(
        (w) => w['workspace_name'] == selectedWorkspace,
        orElse: () => workspaces.first,
      );

      final response = await _supabase
          .from('notes')
          .select()
          .eq('workspace_id', workspace['id'])
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          notes = List<Map<String, dynamic>>.from(response);
          filteredNotes = notes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext)
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

  Future<void> createWorkspaces(String name) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase.from('workspaces').insert({
        'workspace_name': name,
        'created_by': userId,
        'updated_by': userId
      }).select();

      if (mounted) {
        setState(() {
          workspaces.add(response.first);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            SnackBar(content: Text('Error create workspaces: $e')));
      }
    }
  }

  Future<void> loadWorkspaces() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from('workspaces')
          .select()
          .eq('created_by', userId!)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          final uniqueWorkspaces = <String, Map<String, dynamic>>{};
          for (var workspace in response) {
            if (!uniqueWorkspaces.containsKey(workspace['workspace_name'])) {
              uniqueWorkspaces[workspace['workspace_name']] = workspace;
            }
          }
          workspaces = uniqueWorkspaces.values.toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext)
            .showSnackBar(SnackBar(content: Text('Error load workspaces: $e')));
      }
    }
  }

  Future<void> deleteWorkspace(String workspaceName) async {
    try {
      final workspace =
          workspaces.firstWhere((w) => w['workspace_name'] == workspaceName);

      final workspaceId = workspace['id'];
      final now = DateTime.now().toIso8601String();

      await _supabase
          .from('notes')
          .update({'deleted_at': now}).eq('workspace_id', workspaceId);

      await _supabase
          .from('workspaces')
          .update({'deleted_at': now}).eq('id', workspaceId);

      if (mounted) {
        setState(() {
          workspaces.removeWhere((w) => w['workspace_name'] == workspaceName);
          selectedWorkspace = 'Personal';
        });
        await loadNotes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            SnackBar(content: Text('Error deleting workspaces: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                                        color: Colors.white54,
                                        fontFamily: 'Poppins'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.white)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.white)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.white)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                          borderRadius: BorderRadius.circular(12),
                          value: selectedWorkspace,
                          icon: SvgPicture.asset(
                            'assets/icons/ChevronDown.svg',
                            height: 18,
                            width: 18,
                          ),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500),
                          items: [
                            ...workspaces.map((workspace) => DropdownMenuItem(
                                value: workspace['workspace_name'],
                                child: SizedBox(
                                  width: 140,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(
                                        workspace['workspace_name'],
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500),
                                      )),
                                      if (workspace['workspace_name'] !=
                                          'Personal')
                                        GestureDetector(
                                          onTap: () async {
                                            final shouldDelte =
                                                await showDialog<bool>(
                                                    context: context,
                                                    builder:
                                                        (context) =>
                                                            AlertDialog(
                                                              title: const Text(
                                                                'Delete Workspace?',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins'),
                                                              ),
                                                              content: Text(
                                                                'Delete ${workspace['workspace_name']}?',
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Poppins'),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            false),
                                                                    child:
                                                                        const Text(
                                                                      'Cancle',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          color:
                                                                              Colors.black),
                                                                    )),
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            true),
                                                                    child:
                                                                        const Text(
                                                                      'Delete',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                              ],
                                                            ));
                                            if (shouldDelte == true) {
                                              await deleteWorkspace(
                                                  workspace['workspace_name']);
                                            }
                                          },
                                          child: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                        )
                                    ],
                                  ),
                                ))),
                            const DropdownMenuItem(
                                value: 'add_new',
                                child: Row(
                                  children: [
                                    Icon(Icons.add, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add Workspace',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Poppins',
                                          fontSize: 14),
                                    )
                                  ],
                                ))
                          ],
                          onChanged: (value) async {
                            if (value == 'add_new') {
                              final controller = TextEditingController();
                              final name = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Create Workspace',
                                          style:
                                              TextStyle(fontFamily: 'Poppins'),
                                        ),
                                        content: TextField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                              hintText: 'Workspace name',
                                              hintStyle: TextStyle(
                                                  fontFamily: 'Poppins')),
                                          style: const TextStyle(
                                              fontFamily: 'Poppins'),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, null),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins'),
                                              )),
                                          TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, controller.text),
                                              child: const Text(
                                                'Create',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins'),
                                              ))
                                        ],
                                      ));
                              if (name != null && name.isNotEmpty) {
                                await createWorkspaces(name);
                                setState(() {
                                  selectedWorkspace = name;
                                });
                                await loadNotes();
                              } else {
                                return;
                              }
                            } else if (value != null) {
                              setState(() {
                                selectedWorkspace = value;
                              });
                              await loadNotes();
                            }
                          },
                        )),
                      )
                    ],
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
              Row(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    "Welcome back $username",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Poppins'),
                  ),
                )
              ]),
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
