import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputButton extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final VoidCallback? onPressed;
  final String buttonText;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters; // 🔹 입력 제한 추가

  const CustomInputButton({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onPressed,
    required this.buttonText,
    this.obscureText = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: labelText),
            obscureText: obscureText,
            inputFormatters: inputFormatters ?? [], // 🔹 null이면 빈 리스트 전달
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      ],
    );
  }
}
