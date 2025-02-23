// 커뮤니티 설정 (이용 제한 내역, 키워드 설정 등)

import 'package:flutter/material.dart';

class CommunitySettingsScreen extends StatefulWidget {
  const CommunitySettingsScreen({super.key});

  @override
  State<CommunitySettingsScreen> createState() => _CommunitySettingsScreenState();
}

class _CommunitySettingsScreenState extends State<CommunitySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('커뮤니티 설정')),
        body: Text('커뮤니티 설정 화면')
    );
  }
}
