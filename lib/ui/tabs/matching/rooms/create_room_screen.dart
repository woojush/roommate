import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/room_service.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  // 제목 입력 칸 제거 -> _titleController 삭제
  final _descController = TextEditingController();
  bool isLoadingChecklist = true;
  // 체크리스트 정보 저장 (UI에서는 조회 후 화면 표시)
  String? dorm, roomType, gender, dormDuration;

  @override
  void initState() {
    super.initState();
    _checkUserInRoom();
    _loadChecklistData();
  }

  Future<void> _checkUserInRoom() async {
    bool alreadyInRoom = await _isUserInRoom();
    if (alreadyInRoom) {
      // 화면이 완전히 로드된 후 경고창을 띄우고, 확인 후 뒤로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('알림'),
            content: Text('이미 참여하고 있는 방이 있습니다.'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                },
              ),
            ],
          ),
        ).then((_) {
          Navigator.pop(context); // 생성 화면 자체를 닫기
        });
      });
    }
  }

  /// 현재 사용자가 이미 방에 참여 중인지 확인하는 함수
  Future<bool> _isUserInRoom() async {
    final user = await RoomService.getCurrentUser();
    if (user == null) return false;
    final qs = await FirebaseFirestore.instance
        .collection('rooms')
        .where('members', arrayContains: user.uid)
        .get();
    return qs.docs.isNotEmpty;
  }

  Future<void> _loadChecklistData() async {
    var data = await RoomService.fetchUserChecklist();
    setState(() {
      dorm = data?['dorm'] ?? "미정";
      roomType = data?['roomType'] ?? "미정";
      gender = data?['gender'] ?? "미정";
      dormDuration = data?['dormDuration'] ?? "미정";
      isLoadingChecklist = false;
    });
  }

  void _createRoom() async {
    String description = _descController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('비고(설명)을 입력하세요')));
      return;
    }
    if (dorm == null ||
        roomType == null ||
        gender == null ||
        dormDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('체크리스트 정보를 불러오지 못했습니다.')));
      return;
    }
    // 방 제목은 하드코딩("방 제목") 처리
    bool success = await RoomService.createRoom(
      title: '방 제목',
      description: description,
      dorm: dorm!,
      roomType: roomType!,
      gender: gender!,
      dormDuration: dormDuration!,
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(title: '방 생성'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoadingChecklist
                ? Center(child: CircularProgressIndicator())
                : Text(
              "$dorm | $roomType | $dormDuration | $gender",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            // 제목 입력 칸 제거
            // 설명 입력 칸: 모서리가 둥근 네모 박스 스타일
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '비고(설명)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _createRoom, child: Text('생성')),
          ],
        ),
      ),
    );
  }
}
