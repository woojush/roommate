import 'package:flutter/material.dart';
import 'package:findmate1/ui/screens/settings/profile_edit/profile_edit.dart';
import 'package:findmate1/ui/screens/settings/account_settings/account_settings.dart';
import 'package:findmate1/ui/screens/settings/community_settings/community_settings.dart';
import 'package:findmate1/ui/screens/settings/app_settings/app_settings.dart';
import 'package:findmate1/ui/screens/settings/help_center/help_center.dart';
import 'package:findmate1/ui/account/logout_screen.dart';
import 'package:findmate1/widgets/design.dart';  // design.dart 파일 import
import 'package:findmate1/widgets/sub_screen_appbar.dart';
import 'package:findmate1/ui/screens/settings/etc_settings/delete_account.dart';
import '../settings/etc_settings/logout_account.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(title: '설정'),
      body: ListView(
        children: [
          _buildSectionTitle("계정"),
          _buildListTile(context, "아이디", Icons.account_circle, AccountSettingsScreen()),
          _buildListTile(context, "비밀번호 변경", Icons.lock, AccountSettingsScreen()),
          _buildListTile(context, "이메일 변경", Icons.email, AccountSettingsScreen()),

          _buildSectionTitle("커뮤니티"),
          _buildListTile(context, "이용 제한 내역", Icons.block, CommunitySettingsScreen()),
          _buildListTile(context, "관심 키워드 설정", Icons.favorite, CommunitySettingsScreen()),
          _buildListTile(context, "커뮤니티 이용규칙", Icons.rule, CommunitySettingsScreen()),

          _buildSectionTitle("앱 설정"),
          _buildListTile(context, "다크모드", Icons.dark_mode, AppSettingsScreen()),
          _buildListTile(context, "알림 설정", Icons.notifications, AppSettingsScreen()),
          _buildListTile(context, "암호 잠금", Icons.lock_outline, AppSettingsScreen()),
          _buildListTile(context, "캐시 삭제", Icons.delete, AppSettingsScreen()),

          _buildSectionTitle("기타"),
          // 회원 탈퇴는 DeleteAccountTile 위젯을 그대로 사용합니다.
          const DeleteAccountTile(),
          const LogoutTile(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
    );
  }
}
