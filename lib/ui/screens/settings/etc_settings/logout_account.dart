import 'package:flutter/material.dart';
import 'package:findmate1/widgets/warning_dialog.dart';
import 'package:findmate1/service/account/account_service.dart';
import 'package:findmate1/ui/account/login_screen.dart';

class LogoutTile extends StatelessWidget {
  const LogoutTile({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    // 실제 로그아웃 처리
    await AccountService.logout();

    // 로그아웃 후 로그인화면으로 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      // 아래 옵션으로 다이얼로그만 닫히도록 안전하게 처리
      useRootNavigator: false,
      builder: (dialogContext) {
        return WarningDialog(
          title: "로그아웃",
          message: "정말 로그아웃하시겠습니까?",
          buttonCount: 2,
          confirmText: "확인",
          cancelText: "취소",
          onConfirm: () async {
            // 다이얼로그만 닫기
            Navigator.pop(dialogContext);

            // 실제 로그아웃
            await _logout(context);
          },
          onCancel: () {
            // 다이얼로그만 닫기
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app),
      title: const Text("로그아웃"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showLogoutDialog(context),
    );
  }
}
