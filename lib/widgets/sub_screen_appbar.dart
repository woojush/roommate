import 'package:flutter/material.dart';
import 'package:findmate1/theme.dart'; // 테마 적용
import 'package:findmate1/style/font.dart';

class SubScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final double fontSize; // title의 폰트 사이즈 조절
  final VoidCallback? onBackPressed; // 사용자 정의 뒤로가기 동작

  const SubScreenAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.fontSize = 17,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.appBarColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
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
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true, // 제목을 가운데 정렬
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
