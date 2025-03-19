import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/room/room_model.dart';
import 'package:findmate1/widgets/common_card.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onRefresh;
  final bool isMyRoom; // 나의 방 여부 (상위 로직에서 전달받음)
  // 라우트할 화면을 반환하는 함수 (BuildContext를 받아 Widget을 반환)
  final Widget Function(BuildContext context) routeBuilder;

  const RoomCard({
    Key? key,
    required this.room,
    required this.onRefresh,
    this.isMyRoom = false,
    required this.routeBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 현재 시간과 room.createdAt의 차이를 계산하여, 60초 미만이면 "1분 전"으로 표시
    final now = DateTime.now();
    final difference = now.difference(room.createdAt);
    final displayTime = difference.inSeconds < 60 ? "1분 전" : room.timeAgo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        children: [
          CommonCard(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: routeBuilder),
              );
              if (result == true) {
                onRefresh();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  room.description,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(displayTime),
                    Text('${room.views}회 조회됨'),
                    Text(
                      "${room.currentMembers} / ${room.maxMembers}명",
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isMyRoom)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "나의 방",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
