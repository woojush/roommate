import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_idController.text.isEmpty) return _showError("아이디를 입력하세요.");
    if (_passwordController.text.isEmpty) return _showError("비밀번호를 입력하세요.");

    setState(() => _isLoading = true);
    try {
      final query = await _firestore.collection('users').where('id', isEqualTo: _idController.text).get();
      if (query.docs.isEmpty) {
        _showError("존재하지 않는 아이디입니다.");
        setState(() => _isLoading = false);
        return;
      }
      final email = query.docs.first['mail'];
      await _auth.signInWithEmailAndPassword(email: email, password: _passwordController.text);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError("로그인 실패: ${e.toString()}");
    }
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _idController, decoration: InputDecoration(labelText: "아이디")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "비밀번호"), obscureText: true),
            ElevatedButton(onPressed: _login, child: _isLoading ? CircularProgressIndicator() : const Text("로그인")),
            TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                child: const Text("회원가입")
            ),
          ],
        ),
      ),
    );
  }
}
