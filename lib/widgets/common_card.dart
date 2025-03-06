import 'package:flutter/material.dart';

/// ✅ 공통 카드 위젯 (Container 기반, 모든 방향에 그림자 적용)
class CommonCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double cardRadius;
  final List<BoxShadow>? cardShadow;

  const CommonCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.color = Colors.white,
    this.cardRadius = 12,
    this.cardShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: cardShadow ??
              [
                // 모든 방향에 균일한 그림자 적용
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
        ),
        child: child,
      ),
    );
  }
}

/// ✅ 공통 버튼 위젯
class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;

  const CommonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.black,
    this.textColor = Colors.white,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
    );
  }
}

/// ✅ 공통 구분선 위젯
class CommonDivider extends StatelessWidget {
  final double thickness;
  final Color color;
  final double height;

  const CommonDivider({
    Key? key,
    this.thickness = 0.7,
    this.color = Colors.grey,
    this.height = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(color: color, thickness: thickness, height: height);
  }
}
