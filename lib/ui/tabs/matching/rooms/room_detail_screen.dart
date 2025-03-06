import 'package:flutter/material.dart';
import 'package:findmate1/ui/tabs/profile/profile_screen.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';
import 'package:findmate1/service/tabs/matching/room/room_service.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;

  RoomDetailScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? roomData;
  bool _isMember = false;
  bool _isCreatedByMe = false;

  @override
  void initState() {
    super.initState();
    _loadRoom();
    _incrementRoomViews(widget.roomId);
  }

  void _incrementRoomViews(String roomId) async {
    await RoomService.incrementRoomViews(roomId);
  }

  void _requestJoin() async {
    bool result = await RoomService.requestJoin(widget.roomId);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('룸메 신청을 보냈습니다.')),
      );
    }
  }

  void _approveUser(String applicantUid) async {
    await RoomService.approveUser(widget.roomId, applicantUid);
    setState(() {});
  }

  void _rejectUser(String applicantUid) async {
    await RoomService.rejectUser(widget.roomId, applicantUid);
    setState(() {});
  }

  void _viewUserChecklist(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(targetUid: uid),
      ),
    );
  }

  void _loadRoom() async {
    var room = await RoomService.fetchRoom(widget.roomId);
    setState(() {
      roomData = room?.toMap();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('방 정보')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (roomData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('방 정보')),
        body: Center(child: Text('존재하지 않는 방입니다.')),
      );
    }

    return Scaffold(
      appBar: SubScreenAppBar(
        title: '방 상세 정보',
        onBackPressed: () {
          Navigator.pop(context, true);
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${roomData!['title'] ?? ''}', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            Text('방 설명: ${roomData!['description'] ?? ''}'),
            SizedBox(height: 8),
            Text('기숙사 기간: ${roomData!['dormDuration'] ?? '미작성'}'),
            SizedBox(height: 16),
            Text('현재 멤버:'),
            // 멤버 리스트 UI (생략)
            if (!_isMember && !_isCreatedByMe)
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('확인'),
                        content: Text('룸메 요청을 보내시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // 취소 시 다이얼로그 닫기
                              Navigator.of(context).pop();
                            },
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 확인 시 _requestJoin 함수 실행 후 다이얼로그 닫기
                              _requestJoin();
                              Navigator.of(context).pop();
                            },
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('룸메 신청'),
              )
          ],
        ),
      ),
    );
  }
}
