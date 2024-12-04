import 'package:flutter/material.dart';
import 'package:notesapp/pages/home.dart';
import 'package:notesapp/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Loading ..
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Check if there is a valdi current session
          final session = snapshot.hasData ? snapshot.data!.session : null;
          if (session != null) {
            return const Home();
          } else {
            return const LoginPage();
          }
        });
  }
}
