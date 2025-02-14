import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'package:findmate1/screens/main_screen.dart'; // ✅ MainScreen 추가


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
      // 🔹 Firestore에서 'id'로 'email' 찾기
      final query = await _firestore.collection('users')
          .where('id', isEqualTo: _idController.text)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _showError("존재하지 않는 아이디입니다.");
        setState(() => _isLoading = false);
        return;
      }

      final email = query.docs.first['email']; // ✅ Firestore에 저장된 정확한 필드명 확인 필요

      // 🔹 Firebase Authentication 로그인
      await _auth.signInWithEmailAndPassword(
          email: email, password: _passwordController.text
      );

      // 🔹 로그인 성공 시 홈 화면 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );

    } catch (e) {
      _showError("로그인 실패: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupScreen()),
              ),
              child: const Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
