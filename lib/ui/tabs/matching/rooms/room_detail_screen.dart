/// ---------------------------------------------------------------------------
/// 이 파일은 선택한 방의 상세 정보를 표시하는 UI를 제공합니다.
/// - 방 제목, 설명, 기숙사 기간 등 정보를 표시합니다.
/// - 룸메 신청, 승인/거절 등의 상호작용을 위한 버튼과 멤버 리스트를 포함합니다.
/// - 데이터 조회 및 업데이트는 RoomService를 통해 백엔드 로직으로 위임합니다.
/// - 방 상세 정보를 보고 나가면 자동으로 목록이 새로고침됩니다.
/// ---------------------------------------------------------------------------

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


  /// ✅ Firestore에서 방 조회수 증가
  void _incrementRoomViews(String roomId) async {
    await RoomViews.increment(widget.roomId);
  }

  /// ✅ 룸메 신청 기능
  void _requestJoin() async {
    bool result = await RoomService.requestJoin(widget.roomId);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('룸메 신청을 보냈습니다.')),
      );
    }
  }

  /// ✅ 방 신청 승인
  void _approveUser(String applicantUid) async {
    await RoomService.approveUser(widget.roomId, applicantUid);
    setState(() {});
  }

  /// ✅ 방 신청 거절
  void _rejectUser(String applicantUid) async {
    await RoomService.rejectUser(widget.roomId, applicantUid);
    setState(() {});
  }

  /// ✅ 사용자 체크리스트 보기
  void _viewUserChecklist(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(targetUid: uid),
      ),
    );
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
      appBar: SubScreenAppBar(title: '방 상세 정보'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('방 설명: ${roomData!['description'] ?? ''}'),
            SizedBox(height: 8),
            Text('기숙사 기간: ${roomData!['dormDuration'] ?? '미작성'}'),
            SizedBox(height: 16),
            Text('현재 멤버:'),
            // 🔹 멤버 리스트 UI (생략)
            if (!_isMember && !_isCreatedByMe)
              ElevatedButton(
                onPressed: _requestJoin,
                child: Text('룸메 신청'),
              ),
            // 🔹 신청 목록 및 승인/거절 UI (생략)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ✅ 뒤로 갈 때 자동 새로고침을 위해 true 반환
          Navigator.pop(context, true);
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}
