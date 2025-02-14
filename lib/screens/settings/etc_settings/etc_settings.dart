// 기타 (회원 탈퇴, 로그아웃 등)

import 'package:flutter/material.dart';

class EtcSettingsScreen extends StatefulWidget {
  const EtcSettingsScreen({super.key});

  @override
  State<EtcSettingsScreen> createState() => _EtcSettingsScreenState();
}

class _EtcSettingsScreenState extends State<EtcSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('기타 설정')),
        body: Text('기타 설정 화면')
    );
  }
}
