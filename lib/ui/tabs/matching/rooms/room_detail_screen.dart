import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmate1/ui/tabs/profile/profile_screen.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';
import 'package:findmate1/service/tabs/matching/room/room_service.dart';
import 'package:findmate1/widgets/warning_dialog.dart';
import 'package:findmate1/widgets/warning_dialog.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;

  const RoomDetailScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? roomData;

  bool _isMember = false;        // 현재 사용자가 멤버인지 여부
  bool _isCreatedByMe = false;   // 현재 사용자가 방장(owner)인지 여부

  // 실제 멤버들의 프로필 정보 (userName, profileImage 등)을 담을 리스트
  List<Map<String, dynamic>> _memberProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  /// 방 정보 로드 후, 멤버 프로필도 로드
  /// 사용자가 멤버가 아니라면 조회수 증가 처리
  Future<void> _loadRoom() async {
    final roomModel = await RoomService.fetchRoom(widget.roomId);
    final currentUser = FirebaseAuth.instance.currentUser;

    // 방 정보나 현재 유저가 없으면 로딩 종료
    if (roomModel == null || currentUser == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        roomData = null;
      });
      return;
    }

    // roomData 세팅
    if (!mounted) return;
    setState(() {
      roomData = roomModel.toMap();
      _isCreatedByMe = (roomData!['ownerUid'] == currentUser.uid);

      final members = (roomData!['members'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      _isMember = members.contains(currentUser.uid);
    });

    // 멤버 프로필 로드
    await _loadMemberProfiles(roomData!['members']);
    if (!mounted) return;

    // 멤버가 아니라면 조회수 증가
    if (!_isMember) {
      await RoomService.incrementRoomViews(widget.roomId);
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  /// Firestore의 "users" 컬렉션에서 멤버 프로필 정보( userName, profileImage )를 가져옴
  Future<void> _loadMemberProfiles(List<dynamic> memberUids) async {
    _memberProfiles.clear();
    for (String uid in memberUids) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _memberProfiles.add({
          'uid': uid,
          'userName': data['userName'] ?? '사용자',
          'profileImage': data['profileImage'] ?? '',
        });
      } else {
        _memberProfiles.add({
          'uid': uid,
          'userName': '알 수 없음',
          'profileImage': '',
        });
      }
    }
  }

  /// 룸메 신청
  Future<void> _requestJoin() async {
    final result = await RoomService.requestJoin(widget.roomId);
    if (!mounted) return;
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('룸메 신청을 보냈습니다.'),duration: Duration(seconds: 2),),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('룸메 신청에 실패하였습니다.'), duration: Duration(seconds: 2)),
      );
    }
  }

  /// 방 나가기
  Future<void> _leaveRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => WarningDialog(
        title: '방 나가기',
        message: '정말 이 방에서 나가시겠습니까?',
        buttonCount: 2,
        confirmText: '확인',
        cancelText: '취소',
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      )

    );

    if (confirm == true) {
      final success = await RoomService.leaveRoom(widget.roomId, user.uid);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('방에서 나왔습니다.')),
        );
        _loadRoom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('방 나가기에 실패했습니다.')),
        );
      }
    }
  }

  /// 방 삭제
  Future<void> _deleteRoom() async {
    final success = await RoomService.deleteRoom(widget.roomId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방이 삭제되었습니다.')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 삭제에 실패했습니다.')),
      );
    }
  }

  /// 삭제 전 경고창 표시
  Future<void> _confirmDelete() async {
    final members = roomData!['members'] as List<dynamic>;
    final bool hasOtherMembers = (members.length > 1);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => WarningDialog(
        title: hasOtherMembers ? '정말 삭제할까요?' : null,
        message: hasOtherMembers
            ? '룸메이트가 있는 방을 삭제하면 룸메가 당황할 수 있어요'
            : '방을 삭제할까요?',
        buttonCount: 2,
        confirmText: '삭제',
        cancelText: '취소',
      ),
    );

    if (confirm == true) {
      await _deleteRoom();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('방 정보')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (roomData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('방 정보')),
        body: const Center(child: Text('존재하지 않는 방입니다.')),
      );
    }

    return Scaffold(
      appBar: SubScreenAppBar(
        title: '방 상세 정보',
        onBackPressed: () {
          Navigator.pop(context, true);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 방 제목 및 설명
            Text(
              roomData!['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('방 설명: ${roomData!['description'] ?? ''}'),
            const SizedBox(height: 8),
            Text('기숙사 기간: ${roomData!['dormDuration'] ?? '미작성'}'),
            const SizedBox(height: 16),

            // 현재 멤버 목록
            const Text(
              '현재 멤버',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _memberProfiles.isEmpty
                ? const Text('아직 멤버가 없습니다.')
                : Column(
              children: List.generate(_memberProfiles.length, (index) {
                final member = _memberProfiles[index];
                // _isMember가 true면 멤버 이름 그대로, false면 익명표시
                final displayName = _isMember
                    ? (member['userName'] ?? '알 수 없음')
                    : '익명${index + 1}';

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(targetUid: member['uid']),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: (member['profileImage'] ?? '').isNotEmpty
                              ? NetworkImage(member['profileImage'])
                              : const AssetImage("assets/default_profile.png")
                          as ImageProvider,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        // 방장 표시
                        if (member['uid'] == roomData!['ownerUid'])
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '방장',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // 조건에 따른 버튼들 (룸메 신청 또는 방 나가기)
            if (!_isMember && !_isCreatedByMe)
              ElevatedButton(
                onPressed: () async {
                  final alreadyInRoom = await RoomService.isUserInRoom();
                  if (alreadyInRoom) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const WarningDialog(
                          message: '참여 중인 방이 존재합니다.',
                          buttonCount: 1,
                          confirmText: '확인',
                        );
                      },
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return WarningDialog(
                        message: '룸메 신청을 보내시겠습니까?',
                        buttonCount: 2,
                        onConfirm: _requestJoin,
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('룸메 신청', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: Colors.white),),
              ),
            if (_isMember && !_isCreatedByMe)
              ElevatedButton(
                onPressed: _leaveRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('방 나가기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),

            // 하단에 항상 삭제 버튼 (방장이면, 방 인원이 가득 차도 삭제 버튼 표시)
            const SizedBox(height: 16),
            if (_isCreatedByMe)
              ElevatedButton(
                onPressed: _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text(
                  '방 삭제',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
