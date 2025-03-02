import 'package:flutter/material.dart';
import 'package:findmate1/theme.dart'; // ✅ 테마 적용 가능

class SubScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final double FontSize; // title의 폰트 사이즈를 조절할 수 있는 매개변수

  const SubScreenAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.FontSize = 17, // 기본값 20
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.appBarColor, // ✅ 테마 적용
      elevation: 0,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black), // ✅ 뒤로 가기 버튼
        onPressed: () => Navigator.of(context).pop(),
      )
          : null, // ✅ `showBackButton`이 false면 숨김
      title: Text(
        title,
        style: TextStyle(
          fontSize: FontSize, // 사용자 지정 폰트 사이즈 적용
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true, // ✅ 서브 스크린에서는 보통 타이틀이 중앙 정렬됨
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey, // ✅ 구분선 색상
          height: 0.8, // ✅ 구분선 두께
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
