import 'package:flutter/material.dart';
import 'login/login_screen.dart';
import 'package:findmate1/tabs/chat_screen.dart';
import 'package:findmate1/tabs/community_screen.dart';
import 'package:findmate1/tabs/home_screen.dart';
import 'package:findmate1/tabs/matching_screen.dart';
import 'package:findmate1/tabs/info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Firebase 설정 파일
import 'login/logout.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState(); // ✅ 수정
}

class _MainScreenState extends State<MainScreen> {  // ✅ State 클래스명 수정

  int _selectedIndex = 0;

  final List<Widget> _screens =
  [
    Home(), Matching(), Community(), Chating(), Info()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("FindMate"),
        actions: [
          ElevatedButton(
            onPressed: () => signOut(context), // ✅ 로그아웃 함수 실행
            child: const Text('로그아웃'),
          ),
        ],
      ), // ✅ 앱바 추가
      body: Center(
          child: _screens[_selectedIndex]
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "매칭"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "커뮤니티"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "채팅"),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: "기숙사"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // ✅ 선택된 아이콘 색상 추가
        unselectedItemColor: Colors.grey, // ✅ 선택되지 않은 아이콘 색상 추가
        onTap: _onItemTapped,
      ),
    );
  }
}