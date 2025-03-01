import 'package:flutter/material.dart';
import 'package:findmate1/ui/account/login_screen.dart'; // 로그인 창 파일
import 'package:findmate1/ui/tabs/chat_screen.dart'; // 채팅창 탭 파일
import 'package:findmate1/service/tabs/community/post.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_list_screen.dart';
import 'package:findmate1/ui/tabs/community/community_main.dart';
import 'package:findmate1/ui/tabs/profile/profile_screen.dart'; // 메인 화면 파일
import 'package:findmate1/ui/tabs/matching/router/checklist_router.dart'; // 매칭 탭 파일
import 'package:findmate1/ui/tabs/info.dart'; // 기숙사 정보 탭 관련 파일
import 'package:firebase_core/firebase_core.dart';
import 'package:findmate1/config/firebase_options.dart'; // Firebase 설정 파일
import 'package:findmate1/ui/screens/settings/settings_main.dart';  // 설정 관련 파일
import 'package:findmate1/ui/tabs/matching/router/checklist_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ProfileScreen(), ChecklistRouter(), Chating(), CommunityTab(), Info()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "프로필"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "매칭"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "채팅"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "커뮤니티"),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: "기숙사"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // 선택된 아이콘 색상 → 흰색
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이콘 색상 → 회색
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // ✅ 라벨이 항상 보이도록 설정
      ),
    );
  }
}
