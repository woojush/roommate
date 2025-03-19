// lib/ui/tabs/matching/rooms/create_room_screen.dart

import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/room/room_service.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';

class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  // 새로 추가된 방 제목 입력 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool isLoadingChecklist = true;
  String? checklistTitle, dorm, roomType, gender, dormDuration;

  @override
  void initState() {
    super.initState();
    _checkUserInRoom();
    _loadChecklistData();
  }

  Future<void> _checkUserInRoom() async {
    bool alreadyInRoom = await RoomService.isUserInRoom();
    if (alreadyInRoom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('알림'),
            content: const Text('이미 참여하고 있는 방이 있습니다.'),
            actions: [
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ).then((_) {
          Navigator.pop(context);
        });
      });
    }
  }

  Future<void> _loadChecklistData() async {
    var data = await RoomService.fetchUserChecklist();
    setState(() {
      // checklist에서 불러온 제목은 참고용으로만 사용 (사용자가 직접 입력할 수 있도록 TextField를 사용)
      checklistTitle = data?['title'] ?? "미정";
      dorm = data?['dorm'] ?? "미정";
      roomType = data?['roomType'] ?? "미정";
      gender = data?['gender'] ?? "미정";
      dormDuration = data?['dormDuration'] ?? "미정";
      isLoadingChecklist = false;
    });
  }

  /// 사용자가 체크리스트에서 선택한 인실(예:"4인실")에서 숫자만 추출하여 maxMembers로 변환
  int _getMaxMembers() {
    if (roomType != null) {
      // roomType에서 숫자만 추출합니다.
      final numericString = roomType!.replaceAll(RegExp('[^0-9]'), '');
      if (numericString.isNotEmpty) {
        return int.parse(numericString);
      }
    }
    return 2; // 기본값 2
  }

  void _createRoom() async {
    final customTitle = _titleController.text.trim();
    final description = _descController.text.trim();
    if (customTitle.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('방 제목을 입력하세요')));
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('비고(설명)을 입력하세요')));
      return;
    }
    if (dorm == null || roomType == null || gender == null || dormDuration == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('체크리스트 정보를 불러오지 못했습니다.')));
      return;
    }

    int maxMembers = _getMaxMembers();
    bool success = await RoomService.createRoom(
      title: customTitle, // 사용자가 입력한 제목 사용
      description: description,
      dorm: dorm!,
      roomType: roomType!,
      gender: gender!,
      dormDuration: dormDuration!,
      maxMembers: maxMembers,
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(title: '방 생성'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 체크리스트 데이터를 불러오는 동안 로딩 표시
            isLoadingChecklist
                ? const Center(child: CircularProgressIndicator())
                : Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('$dorm'),
                  Text('$roomType'),
                  Text('$dormDuration'),
                  Text('$gender'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 사용자 입력: 방 제목
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '방 제목',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 사용자 입력: 설명
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createRoom,
              child: const Text('생성'),
            ),
          ],
        ),
      ),
    );
  }
}
