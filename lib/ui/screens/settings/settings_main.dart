import 'package:flutter/material.dart';
import 'package:findmate1/ui/screens/settings/profile_edit/profile_edit.dart';
import 'package:findmate1/ui/screens/settings/account_settings/account_settings.dart';
import 'package:findmate1/ui/screens/settings/community_settings/community_settings.dart';
import 'package:findmate1/ui/screens/settings/app_settings/app_settings.dart';
import 'package:findmate1/ui/screens/settings/help_center/help_center.dart';
import 'package:findmate1/ui/screens/settings/etc_settings/etc_settings.dart';
import 'package:findmate1/ui/account/logout_screen.dart';
import 'package:findmate1/widgets/design.dart';  // design.dart 파일 import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("설정")),
      body: ListView(
        children: [
          _buildSectionTitle("내 프로필"),
          _buildListTile(context, "프로필 수정", Icons.person, ProfileEditScreen()),

          _buildSectionTitle("계정"),
          _buildListTile(context, "아이디 변경", Icons.account_circle, AccountSettingsScreen()),
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

          _buildSectionTitle("이용 안내"),
          _buildListTile(context, "앱 버전", Icons.info, HelpCenterScreen()),
          _buildListTile(context, "문의하기", Icons.contact_mail, HelpCenterScreen()),
          _buildListTile(context, "공지사항", Icons.announcement, HelpCenterScreen()),
          _buildListTile(context, "서비스 이용약관", Icons.article, HelpCenterScreen()),
          _buildListTile(context, "개인정보 처리방침", Icons.privacy_tip, HelpCenterScreen()),
          _buildListTile(context, "청소년 보호정책", Icons.policy, HelpCenterScreen()),
          _buildListTile(context, "오픈소스 라이선스", Icons.code, HelpCenterScreen()),

          _buildSectionTitle("기타"),
          _buildListTile(context, "정보 동의 설정", Icons.settings, EtcSettingsScreen()),
          _buildListTile(context, "회원 탈퇴", Icons.exit_to_app, EtcSettingsScreen()),
          _buildListTile(context, "로그아웃", Icons.logout, LogoutScreen()),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
    );
  }
}