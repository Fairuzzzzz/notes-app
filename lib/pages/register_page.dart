import 'package:flutter/material.dart';
import 'package:notesapp/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  // Text Controllers
  final _usernameControllers = TextEditingController();
  final _emailControllers = TextEditingController();
  final _passwordControllers = TextEditingController();
  final _confirmPasswordControllers = TextEditingController();

  void signUp() async {
    final username = _usernameControllers.text;
    final email = _emailControllers.text;
    final password = _passwordControllers.text;
    final confirmPassword = _confirmPasswordControllers.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password don't match")));
      return;
    }

    if (username.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Username is required!")));
      return;
    }

    try {
      await authService.signUpWithEmailPassword(email, password, username);

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        title: const Text(
          "Sign Up",
          style: TextStyle(
              fontFamily: 'Poppins', fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
          children: [
            TextField(
              controller: _usernameControllers,
              decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(fontFamily: 'Poppins')),
              style:
                  const TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
            TextField(
              controller: _emailControllers,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              style:
                  const TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
            TextField(
              controller: _passwordControllers,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontFamily: 'Poppins')),
              style:
                  const TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
            TextField(
              controller: _confirmPasswordControllers,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(fontFamily: 'Poppins')),
              style:
                  const TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
                onPressed: signUp,
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                )),
          ]),
      backgroundColor: Colors.black,
    );
  }
}
