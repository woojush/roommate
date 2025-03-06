import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/room/room_model.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_detail_screen.dart';
import 'package:findmate1/widgets/common_card.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onRefresh;

  const RoomCard({Key? key, required this.room, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0,16, 16),
      child: CommonCard(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(roomId: room.id),
          ),
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
    ));
  }
}
