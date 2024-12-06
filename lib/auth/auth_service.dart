import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth
          .signInWithPassword(email: email, password: password);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password, String username) async {
    final AuthResponse res =
        await _supabase.auth.signUp(email: email, password: password);

    if (res.user != null) {
      await _supabase.from('profiles').insert({
        'id': res.user!.id,
        'username': username,
        'email': email,
        'created_at': DateTime.now().toIso8601String()
      });

      await _supabase.from('workspaces').insert({
        'workspace_name': 'Personal',
        'created_by': res.user!.id,
        'updated_by': res.user!.id
      });
    }
    return res;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<String?> getCurrentUsername() async {
    try {
      final String? userId = _supabase.auth.currentUser?.id;

      if (userId == null) return null;

      final data = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', userId)
          .single();
      return data['username'] as String;
    } catch (e) {
      return null;
    }
  }
}
