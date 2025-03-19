// ui/tabs/matching/rooms/join_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmate1/service/tabs/matching/room/room_service.dart';
import 'package:findmate1/ui/tabs/profile/profile_screen.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';

class JoinRequestsScreen extends StatelessWidget {
  final String roomId;

  const JoinRequestsScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(title: '요청 목록'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .collection('joinRequests')
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('요청이 없습니다.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              // 익명 이름: "익명1", "익명2", ...
              final anonymousName = '익명${index + 1}';
              final timestamp = data['requestedAt'] as Timestamp?;
              final requestedAt =
              timestamp != null ? timestamp.toDate() : DateTime.now();
              return ListTile(
                title: Text('사용자: $anonymousName'),
                subtitle: Text('신청 시각: ${requestedAt.toString()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 프로필 확인 버튼 추가
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.blue),
                      tooltip: '프로필 확인',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(targetUid: data['uid']),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await RoomService.approveUser(roomId, data['uid']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('신청을 수락했습니다.')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await RoomService.rejectUser(roomId, data['uid']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('신청을 거절했습니다.')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
