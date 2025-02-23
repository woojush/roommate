/// ---------------------------------------------------------------------------
/// 이 파일은 커뮤니티 메인 화면을 구성하는 UI를 제공합니다.
/// - 사용자가 '자유게시판'과 '건의사항 게시판' 중 하나를 선택할 수 있는 리스트를 표시합니다.
/// - 각 ListTile을 터치하면 해당 게시판 화면(BoardScreen)으로 내비게이션합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'board_screen.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("커뮤니티")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text("자유게시판"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BoardScreen(boardType: 'free'),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("건의사항 게시판"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BoardScreen(boardType: 'suggestion'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
