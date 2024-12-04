import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notesapp/auth/auth_service.dart';
import 'package:notesapp/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Get auth service
  final authService = AuthService();

  // Text Controllers
  final _emailControllers = TextEditingController();
  final _passwordControllers = TextEditingController();

  void login() async {
    final email = _emailControllers.text;
    final password = _passwordControllers.text;

    // attempt login
    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          const SizedBox(
            height: 24,
          ),
          const Center(
            child: Text(
              'Welcome To Notes App',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          SvgPicture.asset(
            'assets/icons/BookOpen.svg',
            height: 46,
            width: 46,
            color: Colors.white,
          ),
          TextField(
            controller: _emailControllers,
            decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontFamily: 'Poppins')),
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
          ),
          TextField(
            controller: _passwordControllers,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontFamily: 'Poppins')),
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
              onPressed: login,
              child: const Text(
                "Login",
                style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
              )),
          const SizedBox(
            height: 12,
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegisterPage())),
            child: const Center(
                child: Text(
              "Don't have an account? Sign Up",
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            )),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
