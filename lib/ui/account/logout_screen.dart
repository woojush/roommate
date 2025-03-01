/// logout_screen.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 사용자에게 로그아웃 UI를 제공하는 화면입니다.
/// - 로그아웃 버튼을 누르면 AccountService.logout()을 호출하여 로그아웃 처리하고,
///   로그인 화면(LoginScreen)으로 전환합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:findmate1/service/account/account_service.dart';
import 'package:findmate1/ui/account/login_screen.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  /// 로그아웃 버튼 클릭 시 백엔드 서비스 호출 후 로그인 화면으로 이동
  void _signOut(BuildContext context) async {
    await AccountService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _signOut(context),
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
