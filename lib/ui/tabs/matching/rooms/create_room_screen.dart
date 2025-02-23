/// ---------------------------------------------------------------------------
/// 이 파일은 사용자가 새로운 방을 생성할 수 있는 UI를 제공합니다.
/// - 입력 폼: 방 제목, 설명 입력 필드
/// - 체크리스트에서 조회한 사용자 정보(생활관, 인실, 성별, 기숙사 기간)를 표시
/// - 생성 버튼을 누르면 RoomService의 createRoom() 메서드를 호출하여 방 생성 요청을 수행합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/room_service.dart';

class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool isLoadingChecklist = true;
  // 체크리스트 정보 저장 (UI에서는 조회 후 화면 표시)
  String? dorm, roomType, gender, dormDuration;

  @override
  void initState() {
    super.initState();
    _loadChecklistData();
  }

  Future<void> _loadChecklistData() async {
    // 실제 Firestore 조회는 RoomService에서 처리하도록 변경 가능
    var data = await RoomService.fetchUserChecklist();
    setState(() {
      dorm = data['dorm'];
      roomType = data['roomType'];
      gender = data['gender'];
      dormDuration = data['dormDuration'];
      isLoadingChecklist = false;
    });
  }

  void _createRoom() async {
    String title = _titleController.text.trim();
    String description = _descController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('방 제목을 입력하세요')));
      return;
    }
    if (dorm == null || roomType == null || gender == null || dormDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('체크리스트 정보를 불러오지 못했습니다.')));
      return;
    }
    bool success = await RoomService.createRoom(
      title: title,
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
      appBar: AppBar(title: Text('방 생성')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoadingChecklist
                ? Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('생활관: ${dorm ?? "정보 없음"}', style: TextStyle(fontSize: 16)),
                Text('인실: ${roomType ?? "정보 없음"}', style: TextStyle(fontSize: 16)),
                Text('성별: ${gender ?? "정보 없음"}', style: TextStyle(fontSize: 16)),
                Text('기숙사 기간: ${dormDuration ?? "정보 없음"}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
              ],
            ),
            TextField(controller: _titleController, decoration: InputDecoration(labelText: '방 제목')),
            SizedBox(height: 8),
            TextField(controller: _descController, decoration: InputDecoration(labelText: '비고(설명)')),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _createRoom, child: Text('생성')),
          ],
        ),
      ),
    );
  }
}
