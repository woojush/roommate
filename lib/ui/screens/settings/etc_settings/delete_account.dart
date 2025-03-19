import 'package:flutter/material.dart';
import 'package:findmate1/service/account/account_service.dart';
import 'package:findmate1/widgets/warning_dialog.dart';
import 'package:findmate1/main.dart'; // 글로벌 navigatorKey가 선언된 파일

class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({Key? key}) : super(key: key);

  Future<void> _deleteAccount() async {
    try {
      await AccountService.deleteAccount();
      await AccountService.logout();
      // 전역 navigatorKey를 사용해 로그인 화면으로 이동
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("계정 삭제 실패: $e")),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => WarningDialog(
        title: "경고",
        message: "탈퇴하시겠습니까? 계정 정보가 모두 삭제됩니다.",
        buttonCount: 2,
        confirmText: "확인",
        cancelText: "취소",
        onConfirm: () async {
          Navigator.pop(dialogContext); // 다이얼로그 닫기
          await _deleteAccount();
        },
        onCancel: () {
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app),
      title: const Text("회원 탈퇴"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showDeleteDialog(context),
    );
  }
}
