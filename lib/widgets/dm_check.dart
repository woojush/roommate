import 'package:flutter/material.dart';

class DMCheck extends StatelessWidget {
  final String nickname;    // 상대방 익명 닉네임
  final String postTitle;   // 게시물 제목
  final VoidCallback onCancel;
  final VoidCallback onSendDm;

  const DMCheck({
    Key? key,
    required this.nickname,
    required this.postTitle,
    required this.onCancel,
    required this.onSendDm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 바텀시트 높이 늘리기 위해
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        // 원하는 높이 조절
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("다음 프로필로 쪽지를 보냅니다.", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 30,
              // 임의의 프로필
              backgroundImage: AssetImage('assets/default_profile.png'),
            ),
            const SizedBox(height: 8),
            Text(nickname, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // 하단 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 취소
                TextButton(
                  onPressed: onCancel,
                  child: Text("취소", style: TextStyle(color: Colors.red)),
                ),
                // 쪽지 보내기
                ElevatedButton(
                  onPressed: onSendDm,
                  child: Text("쪽지 보내기"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
