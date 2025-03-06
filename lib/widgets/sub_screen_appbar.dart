import 'package:flutter/material.dart';
import 'package:findmate1/theme.dart'; // ✅ 테마 적용 가능

class SubScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final double FontSize; // title의 폰트 사이즈 조절
  final VoidCallback? onBackPressed; // 사용자 정의 뒤로가기 동작

  const SubScreenAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.FontSize = 17,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.appBarColor,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
      )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: FontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey,
          height: 0.8,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
