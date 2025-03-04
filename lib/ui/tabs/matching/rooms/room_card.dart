/// ---------------------------------------------------------------------------
/// 이 파일은 방 목록에서 개별 방 정보를 카드 형태로 표시하는 UI를 제공합니다.
/// - 방 제목, 설명, 조회수, 현재 인원 등을 표시합니다.
/// - 사용자가 방을 클릭하면 RoomDetailScreen으로 이동합니다.
/// - RoomDetailScreen에서 나올 때 자동으로 방 목록이 새로고침됩니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/room/room_model.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_detail_screen.dart';
import 'package:findmate1/widgets/common_card.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onRefresh; // ✅ 방 새로고침을 위한 콜백 추가

  const RoomCard({Key? key, required this.room, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      onTap: () async {
        print("룸 상세 페이지 이동: ${room.id}");

        // ✅ RoomDetailScreen이 닫힐 때 반환 값을 받아옴
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(roomId: room.id),
          ),
        );

        // ✅ RoomDetailScreen에서 `true`를 반환하면 새로고침 실행
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
              Text("${room.timeAgo}"),
              Text('${room.views}회 조회됨'),
              Text(
                "${room.currentMembers} / ${room.maxMembers}명",
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ],
      ),
    );
  }
}
