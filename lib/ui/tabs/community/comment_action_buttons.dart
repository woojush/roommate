import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// DMCheck: 바텀시트 위젯 (닉네임, onSendDm 등 처리)
import 'package:findmate1/widgets/dm_check.dart';
// DMRoomScreen: 실제 DM 화면
import '../chat/dm_room_screen.dart';

class CommentActionButtons extends StatelessWidget {
  final VoidCallback onReply;       // 대댓글 달기
  final VoidCallback onLike;        // 댓글 좋아요
  final VoidCallback onToggleAlarm; // 대댓글 알림 켜기
  final VoidCallback onReport;      // 신고
  final VoidCallback onBlock;       // 차단
  final VoidCallback onSendMessage; // (선택) 쪽지 전송 완료 후 콜백

  final String targetNickname;  // 댓글 작성자 익명 닉네임
  final String postTitle;       // 게시물 제목
  final String boardName;       // 게시판 이름 (예: 자유게시판)
  final String postId;          // 게시물 고유 ID (Firestore)
  final String targetUid;       // 실제 상대방 UID

  const CommentActionButtons({
    Key? key,
    required this.onReply,
    required this.onLike,
    required this.onToggleAlarm,
    required this.onReport,
    required this.onBlock,
    required this.onSendMessage,
    required this.targetNickname,
    required this.postTitle,
    required this.boardName,
    required this.postId,
    required this.targetUid,
  }) : super(key: key);

  // DM 방 ID를 생성하는 함수:
  // postId + 내 UID + 대상 UID 조합 → 유니크 ID (UID는 알파벳 순으로 정렬)
  String _generateDmRoomId(String postId, String myUid, String otherUid) {
    final sorted = [myUid, otherUid]..sort();
    return "DM_${postId}_${sorted[0]}_${sorted[1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.reply, color: Colors.grey),
          iconSize: 15,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: '대댓글 달기',
          onPressed: onReply,
        ),
        _verticalDivider(),
        IconButton(
          icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
          iconSize: 15,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: '좋아요',
          onPressed: onLike,
        ),
        _verticalDivider(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey, size: 15),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onSelected: (value) async {
            switch (value) {
              case 'alarm':
                onToggleAlarm();
                break;
              case 'message':
              // DM 보내기: DMCheck 바텀시트 열기
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  builder: (ctx) {
                    return DMCheck(
                      nickname: targetNickname,
                      postTitle: postTitle,
                      onCancel: () => Navigator.of(ctx).pop(),
                      onSendDm: () async {
                        Navigator.of(ctx).pop(); // 바텀시트 닫기

                        final myUid = FirebaseAuth.instance.currentUser?.uid;
                        if (myUid == null) return;

                        // DM 방 ID 생성 (또는 기존 DM 방 재활용)
                        final dmRoomId = _generateDmRoomId(postId, myUid, targetUid);

                        // Firestore에 DM 방 문서가 없으면 생성 (postTitle도 함께 저장)
                        final dmDocRef = FirebaseFirestore.instance
                            .collection('privateMessages')
                            .doc(dmRoomId);
                        final dmSnapshot = await dmDocRef.get();
                        if (!dmSnapshot.exists) {
                          await dmDocRef.set({
                            'createdAt': FieldValue.serverTimestamp(),
                            'postId': postId,
                            'postTitle': postTitle, // postTitle 저장
                            'members': [myUid, targetUid],
                          });
                        }

                        // DMRoomScreen으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DmRoomScreen(
                              chatRoomId: dmRoomId,
                              postTitle: postTitle,
                              boardName: boardName,
                              targetNickname: targetNickname,
                            ),
                          ),
                        );
                        // 상위 콜백 호출 (옵션)
                        onSendMessage();
                      },
                    );
                  },
                );
                break;
              case 'report':
                onReport();
                break;
              case 'block':
                onBlock();
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'alarm',
              child: Text('대댓글 알림 켜기'),
            ),
            const PopupMenuItem<String>(
              value: 'message',
              child: Text('쪽지 보내기'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'report',
              child: Text('신고'),
            ),
            const PopupMenuItem<String>(
              value: 'block',
              child: Text('차단'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 15,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}
