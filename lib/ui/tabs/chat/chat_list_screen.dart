import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:findmate1/widgets/main_tab_scaffold.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_card.dart';
import 'package:findmate1/ui/tabs/chat/chat_room_screen.dart';
import 'package:findmate1/ui/tabs/chat/personal_chat_list.dart'; // 개인 쪽지 목록
import 'package:findmate1/service/tabs/matching/room/room_model.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("로그인 필요")),
      );
    }

    return MainTabScaffold(
      title: '나의 방',    // 첫 번째 탭 타이틀
      subTitle: '쪽지',  // 두 번째 탭 타이틀
      actions: [
        IconButton(
          onPressed: () {
            // 설정 아이콘 등
          },
          icon: const Icon(Icons.settings),
        ),
      ],

      // ───────────────────────────────────────────
      // 첫 번째 탭: 내가 참여 중인 "rooms" 목록
      // ───────────────────────────────────────────
      firstTabBody: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .where('members', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류 발생'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('참여 중인 방이 없습니다.'));
          }

          final roomCards = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final room = RoomModel.fromMap(data, doc.id);

            // room에 chatRoomId가 있으면 사용, 없으면 room.id를 사용
            final chatRoomId = data['chatRoomId']?.toString().isNotEmpty == true
                ? data['chatRoomId']
                : doc.id;

            return RoomCard(
              room: room,
              isMyRoom: true,
              onRefresh: () {
                // 필요 시 새로고침 로직
              },
              // 방 카드 눌렀을 때 이동할 화면
              routeBuilder: (_) => ChatRoomScreen(
                roomId: chatRoomId,
                roomName: data['title'] ?? '채팅방',
              ),
            );
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              // 별도 로직 없으면 빈 Future
            },
            child: ListView(children: roomCards),
          );
        },
      ),

      // ───────────────────────────────────────────
      // 두 번째 탭: 개인 쪽지 목록 (별도 위젯으로 분리)
      // ───────────────────────────────────────────
      secondTabBody: const PersonalChatListScreen(),
    );
  }
}
