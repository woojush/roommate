import 'package:flutter/material.dart';

class WarningDialog extends StatelessWidget {
  final String? title;
  final String message;
  final int buttonCount;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const WarningDialog({
    Key? key,
    this.title,
    required this.message,
    this.buttonCount = 1,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.onConfirm,
    this.onCancel,
  })  : assert(buttonCount == 1 || buttonCount == 2,
  'buttonCount는 1 또는 2여야 합니다.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null
          ? Text(
        title!,
        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
      )
          : null,
      titlePadding: title == null ? EdgeInsets.zero : null,
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 15, 10),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 17, ),
      ),
      actionsPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      actions: buttonCount == 1
          ? [
        // 단일 버튼: "확인" 버튼 (추가 작업 없이 다이얼로그 닫기)
        Container(
          width: double.infinity,
          height: 40,
          margin: const EdgeInsets.only(left: 24, right: 15, bottom: 15),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 단순 닫기
            },
            child: Text(
              confirmText,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]
          : [
        // 두 개의 버튼 (확인 / 취소)
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(left: 24, right: 4, bottom: 20, top: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () {
                    if (onConfirm != null) {
                      onConfirm!();
                    }
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(left: 4, right: 15, bottom: 20, top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () {
                    if (onCancel != null) {
                      onCancel!();
                    }
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
