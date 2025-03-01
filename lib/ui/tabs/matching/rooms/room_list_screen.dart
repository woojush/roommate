/// room_list_screen.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 사용자의 체크리스트 정보를 기반으로 필터링된 방 목록을 표시하는 UI를 제공합니다.
/// - Firestore 쿼리 결과(방 목록)를 GridView 또는 리스트 형태로 보여줍니다.
/// - 상단에는 프로필(체크리스트 조회)로 이동하는 버튼이 포함됩니다.
/// - FloatingActionButton을 통해 방 생성 화면으로 이동할 수 있습니다.
/// - 방 추천 알고리즘을 적용하여 사용자와 가장 적합한 방을 우선 추천합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/service/tabs/matching/room_service.dart';
import 'package:findmate1/service/tabs/matching/room_model.dart';
import 'package:findmate1/widgets/room_card.dart';
import 'package:findmate1/ui/tabs/matching/rooms/profile_screen.dart';
import 'package:findmate1/ui/tabs/matching/rooms/create_room_screen.dart';

class RoomListScreen extends StatefulWidget {
  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  bool _isChecklistLoaded = false;
  Map<String, dynamic>? userChecklist;
  List<RoomModel> filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  /// 사용자의 체크리스트 로드 (1차 필터링 조건 포함)
  Future<void> _loadChecklist() async {
    userChecklist = await RoomService.fetchUserChecklist();
    if (userChecklist != null) {
      setState(() {
        _isChecklistLoaded = true;
      });
    }
  }

  /// 방 필터링 및 정렬 (1차 필터링 + 2차 필터링)
  List<RoomModel> filterAndSortRooms(List<RoomModel> rooms) {
    if (userChecklist == null) return rooms;

    // 🟢 1차 필터링: 생활관, 성별, 기숙사 기간, 인실이 동일한 방만 선택
    List<RoomModel> firstFilteredRooms = rooms.where((room) {
      return room.dorm == userChecklist!['dorm'] &&
          room.roomType == userChecklist!['roomType'] &&
          room.gender == userChecklist!['gender'] &&
          room.dormDuration == userChecklist!['dormDuration'];
    }).toList();

    // 🟢 2차 필터링: 우선순위 항목과 매칭 점수를 계산
    List<Map<String, dynamic>> scoredRooms = firstFilteredRooms.map((room) {
      int matchScore = RoomService.calculateMatchScore(userChecklist!, room);
      return {'room': room, 'score': matchScore};
    }).toList();

    // 점수 기준으로 정렬 (내림차순)
    scoredRooms.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // 최종 정렬된 방 목록 반환
    return scoredRooms.map((entry) => entry['room'] as RoomModel).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isChecklistLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text("룸메이트 찾기")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("룸메이트 찾기"),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(targetUid: user.uid),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: RoomService.fetchRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("방 목록을 가져오는 데 실패했습니다."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("조건에 맞는 방이 없습니다."));
          }

          final docs = snapshot.data!.docs;
          List<RoomModel> rooms = docs
              .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          // 🟢 필터링 및 정렬 적용
          filteredRooms = filterAndSortRooms(rooms);

          return filteredRooms.isEmpty
              ? Center(child: Text("조건에 맞는 방이 없습니다."))
              : GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3,
            ),
            itemCount: filteredRooms.length,
            itemBuilder: (context, index) {
              return RoomCard(room: filteredRooms[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateRoomScreen()),
          );
        },
        label: Text('방 만들기', style: TextStyle(color: Colors.white),),
        icon: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(150),  // 🔹 원하는 둥글기 조절 가능
        ),
      ),
    );
  }
}
