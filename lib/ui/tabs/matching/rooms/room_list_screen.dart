import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmate1/service/tabs/matching/room_service.dart';
import 'package:findmate1/service/tabs/matching/room_model.dart';
import 'package:findmate1/widgets/common_card.dart';
import 'package:findmate1/ui/tabs/matching/rooms/create_room_screen.dart';
import 'package:findmate1/widgets/main_tab_appbar.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_detail_screen.dart';

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

    List<RoomModel> firstFilteredRooms = rooms.where((room) {
      return room.dorm == userChecklist!['dorm'] &&
          room.roomType == userChecklist!['roomType'] &&
          room.gender == userChecklist!['gender'] &&
          room.dormDuration == userChecklist!['dormDuration'];
    }).toList();

    List<Map<String, dynamic>> scoredRooms = firstFilteredRooms.map((room) {
      int matchScore = RoomService.calculateMatchScore(userChecklist!, room);
      return {'room': room, 'score': matchScore};
    }).toList();

    scoredRooms.sort((a, b) =>
        (b['score'] as int).compareTo(a['score'] as int));

    return scoredRooms.map((entry) => entry['room'] as RoomModel).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isChecklistLoaded) {
      return Scaffold(
        appBar: MainTabAppBar(title: "룸메이트 찾기"),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: MainTabAppBar(
        title: "룸메이트 찾기",
        actions: [
          IconButton(
            icon: Icon(Icons.mail),
            onPressed: () {
              // 프로필 화면 등 다른 동작을 추가할 수 있습니다.
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
              .map((doc) => RoomModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          // 필터링 및 정렬 적용
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
              final room = filteredRooms[index];
              return CommonCard(
                onTap: () {
                  // 방 클릭 시 상세 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RoomDetailScreen(roomId: room.id),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 사용자가 이미 방에 참여 중인지 확인
          final user = await RoomService.getCurrentUser();
          if (user != null) {
            final qs = await FirebaseFirestore.instance
                .collection('rooms')
                .where('members', arrayContains: user.uid)
                .get();
            if (qs.docs.isNotEmpty) {
              // 이미 참여 중이면 경고창 표시하고 생성 화면으로 이동하지 않음.
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  contentPadding: EdgeInsets.fromLTRB(24, 20, 15, 20),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  content: Text(
                    '이미 참여하고 있는 방이 있습니다.',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '확인',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              );
              return;
            }
          }
          // 참여 중이 아니라면 생성 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateRoomScreen()),
          );
        },
        label: Text('방 만들기', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(150),
        ),
      ),
    );
  }
}
