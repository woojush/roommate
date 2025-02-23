/// login_screen.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 사용자에게 로그인 UI를 제공하는 화면입니다.
/// - 사용자가 아이디와 비밀번호를 입력하면,
///   AccountService.login()을 호출하여 백엔드에서 로그인 처리를 수행합니다.
/// - 로그인 성공 시 메인 화면(MainScreen)으로 이동합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import 'package:findmate1/ui/screens/main_screen.dart';
import 'package:findmate1/service/account/account_service.dart'; // 서비스 파일 import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    // 입력값 검증
    if (_idController.text.isEmpty) return _showError("아이디를 입력하세요.");
    if (_passwordController.text.isEmpty) return _showError("비밀번호를 입력하세요.");

    setState(() => _isLoading = true);

    try {
      // 백엔드 서비스(AccountService)를 통해 로그인 처리
      await AccountService.login(
        id: _idController.text,
        password: _passwordController.text,
      );

      // 로그인 성공 시 메인 화면으로 이동
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
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: "아이디"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "비밀번호"),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: _isLoading ? CircularProgressIndicator() : const Text("로그인"),
            ),
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
