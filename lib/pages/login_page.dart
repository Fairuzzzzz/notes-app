import 'package:flutter/material.dart';
import 'package:notesapp/pages/home.dart';
import 'package:notesapp/services/database_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username != null) {
        final user = await DatabaseService.instance.getUser(username);
        if (user != null && mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Home(
                      userId: user[DatabaseService.instance.userIdColumn])));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking login state $e')));
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();

      // Get or Create User
      final user = await DatabaseService.instance.getUser(username);
      int userId;

      if (user != null) {
        userId = user['id'] as int;
      } else {
        userId = await DatabaseService.instance.createUser(username);
      }

      // Save Login State
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home(userId: userId)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome To App",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 18,
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
