import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/room/room_service.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';

class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _descController = TextEditingController();
  bool isLoadingChecklist = true;
  String? title, dorm, roomType, gender, dormDuration;

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
            title: Text('알림'),
            content: Text('이미 참여하고 있는 방이 있습니다.'),
            actions: [
              TextButton(
                child: Text('확인'),
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
      title = data?['title'] ?? "미정";
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
    if (dorm == null || roomType == null || gender == null || dormDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('체크리스트 정보를 불러오지 못했습니다.')));
      return;
    }
    bool success = await RoomService.createRoom(
      title: title!,
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
                : Container(
              decoration: BoxDecoration(border: Border.all(width: 2)),
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
            SizedBox(height: 16),
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
