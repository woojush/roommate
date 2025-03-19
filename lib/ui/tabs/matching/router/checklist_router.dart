import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/ui/tabs/matching/checklist/checklist_screen.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_list_screen.dart';
import 'package:findmate1/widgets/main_tab_appbar.dart';
import 'package:findmate1/service/tabs/matching/room/room_model.dart';

class ChecklistRouter extends StatefulWidget {
  const ChecklistRouter({Key? key}) : super(key: key);

  @override
  _ChecklistRouterState createState() => _ChecklistRouterState();
}

class _ChecklistRouterState extends State<ChecklistRouter> {
  bool _isChecklistComplete = false;
  bool _isLoading = true;
  RoomModel? _userRoom; // 사용자의 방 정보 저장

  @override
  void initState() {
    super.initState();
    // UI 빌드 완료 후 _checkChecklistStatus 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkChecklistStatus();
    });
  }

  /// Firestore에서 'checklists/{uid}' 문서를 조회하여 체크리스트 작성 여부 확인
  Future<void> _checkChecklistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("사용자가 로그인되어 있지 않습니다.");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    print("현재 로그인한 사용자 UID: ${user.uid}");

    // 체크리스트 문서 가져오기
    final checklistDoc = await FirebaseFirestore.instance
        .collection('checklists')
        .doc(user.uid)
        .get();

    bool checklistExists = checklistDoc.exists;
    RoomModel? userRoom;

    // 사용자의 방 정보 가져오기 (해당 유저가 포함된 방 조회)
    final roomQuery = await FirebaseFirestore.instance
        .collection('rooms')
        .where('members', arrayContains: user.uid)
        .limit(1)
        .get();

    if (roomQuery.docs.isNotEmpty) {
      userRoom = RoomModel.fromMap(
          roomQuery.docs.first.data(), roomQuery.docs.first.id);
    }

    // 위젯이 아직 마운트되어 있는지 확인
    if (!mounted) return;
    setState(() {
      _isChecklistComplete = checklistExists;
      _userRoom = userRoom;
      _isLoading = false;
    });

    print("Firestore 경로 (${checklistDoc.reference.path})의 문서 존재 여부: $checklistExists");
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 체크리스트 미작성 → 체크리스트 작성 화면 표시
    if (!_isChecklistComplete) {
      return Scaffold(
        appBar: MainTabAppBar(title: '룸메이트 매칭'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('체크리스트가 작성되지 않았습니다.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // ChecklistScreen에서 완료 후 true 반환
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChecklistScreen(),
                    ),
                  );
                  if (result == true) {
                    if (mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _checkChecklistStatus();
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // 배경색
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '체크리스트 작성',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )],
          )
        ),
      );
    }

    // 체크리스트 작성 완료 → 방 목록 화면 (방 정보가 없으면 기본값 전달)
    return RoomListScreen(
      room: _userRoom ??
          RoomModel(
            id: "default",
            title: "룸메이트 찾기",
            description: "현재 방이 없습니다.",
            dorm: "미정",
            roomType: "미정",
            gender: "미정",
            dormDuration: "미정",
            ownerUid: "",
            members: [],
            joinRequests: [],
            createdAt: DateTime.now(),
            checklist: {},
            maxMembers: 2,
            views: 0,
          ),
    );
  }
}
