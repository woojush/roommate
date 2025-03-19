import 'package:flutter/material.dart';
import 'comment_action_buttons.dart';

class CommentItem extends StatelessWidget {
  final String nickname;
  final String commentText;
  final String timeString;  // 예: "03/17 23:09"
  final int likeCount;      // 댓글 좋아요 수

  // 각 버튼에 대한 콜백
  final VoidCallback onReply;
  final VoidCallback onLike;
  final VoidCallback onToggleAlarm;
  final VoidCallback onSendMessage;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  // DM 생성 및 이동을 위해 필요한 추가 파라미터
  final String postTitle;  // 게시물 제목
  final String boardName;  // 게시판 이름 (예: "자유게시판")
  final String postId;     // 게시물 고유 ID (Firestore)
  final String targetUid;  // 실제 상대방 UID

  const CommentItem({
    Key? key,
    required this.nickname,
    required this.commentText,
    required this.timeString,
    required this.likeCount,
    required this.onReply,
    required this.onLike,
    required this.onToggleAlarm,
    required this.onSendMessage,
    required this.onReport,
    required this.onBlock,
    required this.postTitle,
    required this.boardName,
    required this.postId,
    required this.targetUid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 첫 번째 줄: 프로필 아이콘, 닉네임, 오른쪽 버튼 그룹
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 왼쪽: 프로필 아이콘과 닉네임
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundImage: AssetImage('assets/default_profile.png'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nickname,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // 오른쪽: DM 등 액션 버튼 그룹
                  CommentActionButtons(
                    onReply: onReply,
                    onLike: onLike,
                    onToggleAlarm: onToggleAlarm,
                    onReport: onReport,
                    onBlock: onBlock,
                    onSendMessage: onSendMessage,
                    targetNickname: nickname,
                    postTitle: postTitle,
                    boardName: boardName,
                    postId: postId,
                    targetUid: targetUid,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 두 번째 줄: 댓글 본문
              Text(
                commentText,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              // 세 번째 줄: 작성 시간과 좋아요 아이콘 및 개수
              Row(
                children: [
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '$likeCount',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 0.2,
          color: Colors.grey,
        ),
      ],
    );
  }
}
