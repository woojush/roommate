// 앱의 메인 화면

import 'package:flutter/material.dart';
import 'package:findmate1/ui/screens/settings/settings_main.dart';  // 설정 관련 파일

class Home extends StatelessWidget {
  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('홈'),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()), // ✅ 변경
          ),)
        ],
      ), // ✅ 앱바 추가
    );
  }
}
