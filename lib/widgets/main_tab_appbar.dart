import 'package:flutter/material.dart';
import 'package:findmate1/theme.dart'; // ✅ 앱 테마 색상 적용

class MainTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // ✅ 제목 (좌측 상단)
  final List<Widget>? actions; // ✅ 우측 상단 버튼 (옵션)

  const MainTabAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 0, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ 좌우 배치
          children: [
            // ✅ 제목 (좌측 정렬)
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // ✅ 우측 버튼 영역 (설정 버튼 등)
            Row(
              children: actions != null
                  ? actions!.map((action) => Transform.translate(
                offset: Offset(0, -5), // Y축으로 5픽셀 위로 이동
                child: action,
              )).toList()
                  : [],
            ),

          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60); // ✅ 높이 조정 가능
}
