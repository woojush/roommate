import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findmate1/service/tabs/matching/room_provider.dart';

class RoomFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoomProvider>(context);
    final userChecklist = provider.userChecklist;

    if (userChecklist == null) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${userChecklist['dorm']} / ${userChecklist['roomType']} / ${userChecklist['dormDuration']} / ${userChecklist['gender']}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // ✅ 필터 기능 추가 예정
            },
          ),
        ],
      ),
    );
  }
}
