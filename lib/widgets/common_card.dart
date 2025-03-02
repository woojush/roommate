import 'package:flutter/material.dart';

/// 공통 카드 위젯: onTap, padding, elevation, 색상, 테두리 등 기본 스타일을 지정합니다.
class CommonCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color color;
  final ShapeBorder? shape;

  const CommonCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 3,
    this.color = Colors.white,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: elevation,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
