// lib/widgets/design.dart
import 'package:flutter/material.dart';

/// 섹션 제목 위젯 (예: "내 프로필", "계정" 등)
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 리스트 항목 위젯 (설정 화면의 ListTile과 유사)
class CustomListTile extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const CustomListTile({
    Key? key,
    required this.title,
    this.icon,
    this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
