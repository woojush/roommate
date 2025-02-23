/// logout_screen.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 사용자가 로그아웃할 때 보여지는 UI를 제공합니다.
/// - '확인' 버튼을 누르면 AccountService.logout()을 호출하여 로그아웃 처리 후,
///   로그인 화면(LoginScreen)으로 이동합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:findmate1/ui/account/login_screen.dart';
import 'package:findmate1/service/account/account_service.dart'; // 서비스 파일 import

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  /// 로그아웃 버튼이 눌렸을 때, 백엔드 서비스로 로그아웃 처리 후 화면 전환
  void _signOut(BuildContext context) async {
    await AccountService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // 이전 화면 스택 모두 제거
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
                  onPressed: () => Navigator.pop(context), // 취소
                  child: const Text("취소"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _signOut(context), // 로그아웃 실행
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
