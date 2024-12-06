import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
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
}
