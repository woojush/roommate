/// room_card.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 매칭(룸) 목록에서 각 방(RoomModel)의 요약 정보를 카드 형태로 표시하는
/// UI 위젯을 정의합니다.
/// - RoomCard 위젯은 방의 제목, 기숙사 정보(생활관, 기숙사 기간, 인실, 성별),
///   그리고 간단한 설명을 표시하며, 터치 시 방 상세 화면(RoomDetailScreen)으로 내비게이션합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/room_model.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_detail_screen.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;

  const RoomCard({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailScreen(roomId: room.id),
            ),
          );
        },
        child: Container(
          height: 120, // 카드 고정 높이
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 방 대표 아이콘 영역 (예: 집 아이콘)
              Container(
                width: 120,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.home,
                    size: 40,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 방 정보 표시 영역
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 방 제목
                    Text(
                      room.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 기숙사 정보 (생활관 | 기숙사 기간 | 인실 | 성별)
                    Text(
                      '${room.dorm} | ${room.dormDuration} | ${room.roomType} | ${room.gender}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 방 설명
                    Text(
                      room.description,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
