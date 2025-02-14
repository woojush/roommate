import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  // ✅ 로그아웃 함수
  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // 기존 화면 스택 모두 제거 (뒤로 가기 방지)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그아웃")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("정말 로그아웃하시겠습니까?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context), // ❌ 취소
                  child: const Text("취소"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => signOut(context), // ✅ 로그아웃 실행
                  child: const Text("확인"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
