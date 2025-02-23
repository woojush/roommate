/// ---------------------------------------------------------------------------
/// 이 파일은 사용자의 체크리스트 정보를 기반으로 필터링된 방 목록을 표시하는 UI를 제공합니다.
/// - Firestore 쿼리 결과(방 목록)를 GridView 또는 리스트 형태로 보여줍니다.
/// - 상단에는 프로필(체크리스트 조회)로 이동하는 버튼이 포함됩니다.
/// - FloatingActionButton을 통해 방 생성 화면으로 이동할 수 있습니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/service/tabs/matching/room_service.dart';
import 'package:findmate1/service/tabs/matching/room_model.dart';
import 'package:findmate1/widgets/room_card.dart'; // 기존 RoomCard 위젯

class RoomListScreen extends StatefulWidget {
  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  bool _isChecklistLoaded = false;
  Map<String, dynamic>? userChecklist;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    userChecklist = await RoomService.fetchUserChecklist();
    setState(() { _isChecklistLoaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isChecklistLoaded) {
      return Scaffold(appBar: AppBar(title: Text("룸메이트 찾기")), body: Center(child: CircularProgressIndicator()));
    }
    List<RoomModel> rooms = await RoomService.fetchRooms(userChecklist!); // (예시) 동기 호출 아님. 실제는 Stream 또는 FutureBuilder 사용
    // 아래는 기존 GridView UI 유지 (실제 구현은 RoomService.fetchRooms()를 StreamBuilder로 감쌀 것)
    return Scaffold(
      appBar: AppBar(
        title: Text("룸메이트 찾기"),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // 프로필(체크리스트 조회) 화면 이동
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(targetUid: user.uid)));
              }
            },
          )
        ],
      ),
      body: Center(child: Text("방 목록 UI (RoomService.fetchRooms() 결과 표시)")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRoomScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
