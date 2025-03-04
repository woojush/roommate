import 'package:flutter/material.dart';

class RoomFilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RoomFilterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_list, size: 28, color: Colors.black),
      onPressed: onPressed,
      tooltip: "필터 설정",
    );
  }
}
