import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'dm_room_screen.dart';

class PersonalChatListScreen extends StatelessWidget {
  const PersonalChatListScreen({Key? key}) : super(key: key);

  String _formatTime(Timestamp timestamp) {
    final dt = timestamp.toDate();
    final now = DateTime.now();
    // 오늘 날짜와 비교: 년, 월, 일이 같으면 오늘
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      // 오늘이면 시간만 표시 (예: 14:30)
      return DateFormat('HH:mm').format(dt);
    } else {
      // 오늘이 아니면 날짜와 시간 모두 표시 (예: 03/14 11:35)
      return DateFormat('MM/dd HH:mm').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text("로그인 필요"));
    }

    print('[PersonalChatListScreen] 현재 사용자 UID: ${currentUser.uid}');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('privateMessages')
          .where('members', arrayContains: currentUser.uid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('[PersonalChatListScreen] 오류 발생: ${snapshot.error}');
          return Center(child: Text("오류 발생: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('[PersonalChatListScreen] 대기중(loading)');
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        print('[PersonalChatListScreen] 쿼리 결과 문서 수: ${docs.length}');

        if (docs.isEmpty) {
          print('[PersonalChatListScreen] 쿼리 결과가 비어 있습니다.');
          return const Center(child: Text("쪽지 대화가 없습니다."));
        }

        // 디버그: 각 문서 출력
        for (int i = 0; i < docs.length; i++) {
          final dmDoc = docs[i];
          final data = dmDoc.data() as Map<String, dynamic>;
          final docId = dmDoc.id;
          print('[PersonalChatListScreen] #$i 문서ID: $docId, 데이터: $data');
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final dmDoc = docs[index];
            final data = dmDoc.data() as Map<String, dynamic>;
            final docId = dmDoc.id;

            // 마지막 메시지 및 시간
            final lastMessage = data['lastMessage'] ?? "";
            final lastMsgTime = data['lastMessageTime'] as Timestamp?;
            final timeString = lastMsgTime != null ? _formatTime(lastMsgTime) : "";

            // members = [내UID, 상대UID]
            final members = List<String>.from(data['members'] ?? []);
            String otherUid = "";
            for (final uid in members) {
              if (uid != currentUser.uid) {
                otherUid = uid;
                break;
              }
            }

            // 게시물 정보 (옵션)
            final postTitle = data['postTitle'] ?? "게시물 제목";
            final boardName = data['boardName'] ?? "게시판 이름";

            // 상대 닉네임 (participantNicks를 쓴다면 거기서 꺼내기)
            final otherNickname = "익명";

            return ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('assets/default_profile.png'),
              ),
              title: Text(postTitle),
              subtitle: Text(lastMessage),
              trailing: Text(timeString),
              onTap: () {
                print('[PersonalChatListScreen] 채팅방 "$docId" 클릭');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DmRoomScreen(
                      chatRoomId: docId,
                      postTitle: postTitle,
                      boardName: boardName,
                      targetNickname: otherNickname,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
