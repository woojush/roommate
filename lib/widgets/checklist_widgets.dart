// lib/widgets/checklist_widgets.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findmate1/service/tabs/matching/checklist/checklist_item.dart';
import 'package:findmate1/service/tabs/matching/checklist/checklist_provider.dart';

/// (1) CupertinoPickerWidget: picker 타입 질문에 사용
class CupertinoPickerWidget extends StatefulWidget {
  final ChecklistQuestion question;
  final Function(String) onSelected;

  const CupertinoPickerWidget({
    Key? key,
    required this.question,
    required this.onSelected,
  }) : super(key: key);

  @override
  _CupertinoPickerWidgetState createState() => _CupertinoPickerWidgetState();
}

class _CupertinoPickerWidgetState extends State<CupertinoPickerWidget> {
  late List<String> options;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    options = (widget.question.options as List?)?.cast<String>() ?? [];

    final provider = Provider.of<ChecklistProvider>(context, listen: false);
    final currentValue = provider.checklistAnswers[widget.question.id];

    // 현재 값이 String이고 options 목록에 포함되어 있으면 해당 인덱스로
    if (currentValue is String && options.contains(currentValue)) {
      selectedIndex = options.indexOf(currentValue);
    } else {
      // 없으면 맨 마지막 인덱스로 설정
      selectedIndex = options.isNotEmpty ? options.length - 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);
    final currentVal = provider.checklistAnswers[widget.question.id];
    final displayText = (currentVal is String) ? currentVal : "선택";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (_) => Container(
                height: 300,
                color: Colors.white,
                child: Column(
                  children: [
                    // 상단의 취소/확인 버튼
                    Container(
                      height: 50,
                      color: Colors.grey.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            child: const Text("취소"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoButton(
                            child: const Text("확인"),
                            onPressed: () {
                              if (selectedIndex < options.length) {
                                widget.onSelected(options[selectedIndex]);
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    // 실제 Picker 영역
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                        backgroundColor: Colors.white,
                        itemExtent: 30,
                        onSelectedItemChanged: (idx) {
                          setState(() => selectedIndex = idx);
                        },
                        children: options.map((e) => Center(child: Text(e))).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(displayText),
          ),
        ),
      ],
    );
  }
}

/// (2) ButtonSelectionWidget: button 타입 질문 (단일/다중 선택 지원)
class ButtonSelectionWidget extends StatefulWidget {
  final ChecklistQuestion question;
  final Function(dynamic) onSelected;
  final dynamic selectedValue;

  const ButtonSelectionWidget({
    Key? key,
    required this.question,
    required this.onSelected,
    this.selectedValue,
  }) : super(key: key);

  @override
  _ButtonSelectionWidgetState createState() => _ButtonSelectionWidgetState();
}

class _ButtonSelectionWidgetState extends State<ButtonSelectionWidget> {
  late dynamic selectedValueLocal;

  @override
  void initState() {
    super.initState();

    // Firestore에서 불러온 값(= widget.selectedValue)
    selectedValueLocal = widget.selectedValue;

    // multiSelect == true 이면 List<String> 형태여야 함
    if (widget.question.multiSelect) {
      // Firestore에서는 List<dynamic>으로 들어올 수 있으므로, 명시적 변환
      if (selectedValueLocal is List) {
        // [유동적, 아침] 처럼 이미 배열이라면 List<String>으로 캐스팅
        selectedValueLocal = List<String>.from(selectedValueLocal);
      } else if (selectedValueLocal is String) {
        // 혹시 "유동적, 아침" 같은 문자열로 저장된 경우
        selectedValueLocal = (selectedValueLocal as String)
            .split(',')
            .map((e) => e.trim())
            .toList();
      } else {
        // 그 외 (null 등)인 경우 빈 배열로
        selectedValueLocal = <String>[];
      }
    } else {
      // 단일 선택
      selectedValueLocal = selectedValueLocal as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> options = (widget.question.options as List?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            bool isSelected = false;
            if (widget.question.multiSelect) {
              isSelected = (selectedValueLocal as List<String>).contains(option);
            } else {
              isSelected = (selectedValueLocal == option);
            }
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  if (widget.question.multiSelect) {
                    // 토글 방식
                    if ((selectedValueLocal as List<String>).contains(option)) {
                      (selectedValueLocal as List<String>).remove(option);
                    } else {
                      (selectedValueLocal as List<String>).add(option);
                    }
                  } else {
                    selectedValueLocal = option;
                  }
                });
                // 최종 선택된 배열(또는 단일 값)을 Provider로 전달
                widget.onSelected(selectedValueLocal);
              },
              child: Text(option, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// (3) CupertinoTimePickerWidget: iOS 스타일 시간 선택 위젯 (timeIos 타입)
class CupertinoTimePickerWidget extends StatefulWidget {
  final String title;
  final DateTime initialTime;
  final Function(DateTime) onTimeSelected;
  final bool use24hFormat;

  const CupertinoTimePickerWidget({
    Key? key,
    required this.title,
    required this.initialTime,
    required this.onTimeSelected,
    this.use24hFormat = false,
  }) : super(key: key);

  @override
  _CupertinoTimePickerWidgetState createState() => _CupertinoTimePickerWidgetState();
}

class _CupertinoTimePickerWidgetState extends State<CupertinoTimePickerWidget> {
  late DateTime tempPickedTime;

  @override
  void initState() {
    super.initState();
    tempPickedTime = widget.initialTime;
  }

  Future<void> _showTimePicker(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text("취소"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text("확인"),
                    onPressed: () {
                      widget.onTimeSelected(tempPickedTime);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: widget.use24hFormat,
                initialDateTime: tempPickedTime,
                onDateTimeChanged: (newDateTime) {
                  setState(() {
                    tempPickedTime = newDateTime;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime, bool use24h) {
    if (use24h) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    } else {
      final hour = dateTime.hour == 0
          ? 12
          : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
      final ampm = dateTime.hour < 12 ? "오전" : "오후";
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return "$ampm $hour:$minute";
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeString = _formatTime(tempPickedTime, widget.use24hFormat);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showTimePicker(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(timeString),
          ),
        ),
      ],
    );
  }
}

/// (4) TextInputWidget: 단답형 입력 위젯 (hintText 및 초기값 지원)
class TextInputWidget extends StatefulWidget {
  final ChecklistQuestion question;
  final Function(String) onChanged;
  final String? initialValue;
  final String? hintText;

  const TextInputWidget({
    Key? key,
    required this.question,
    required this.onChanged,
    this.initialValue,
    this.hintText,
  }) : super(key: key);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          maxLines: 6,
          minLines: 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: widget.hintText ?? '여기에 작성해주세요',
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// (5) MBTISelectionWidget: MBTI 선택 위젯 (2차원 배열)
class MBTISelectionWidget extends StatefulWidget {
  final ChecklistQuestion question;
  final Function(String) onSelected;
  final String? selectedValue;

  const MBTISelectionWidget({
    Key? key,
    required this.question,
    required this.onSelected,
    this.selectedValue,
  }) : super(key: key);

  @override
  _MBTISelectionWidgetState createState() => _MBTISelectionWidgetState();
}

class _MBTISelectionWidgetState extends State<MBTISelectionWidget> {
  String? selectedMBTI;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChecklistProvider>(context, listen: false);
    final currentVal = provider.checklistAnswers[widget.question.id];
    if (currentVal is String) {
      selectedMBTI = currentVal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<List<String>> mbtiGroups =
        (widget.question.options as List?)?.map<List<String>>((e) {
          return (e as List).cast<String>();
        }).toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // mbtiGroups: [[I, E], [S, N], [F, T], [P, J]]
        ...mbtiGroups.asMap().entries.map((entry) {
          final groupIndex = entry.key;
          final groupOptions = entry.value;

          return Wrap(
            spacing: 8,
            children: groupOptions.map((option) {
              bool isSelected = false;
              if (selectedMBTI != null && selectedMBTI!.length == mbtiGroups.length) {
                isSelected = selectedMBTI![groupIndex] == option;
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  final length = mbtiGroups.length;
                  List<String> chars;
                  if (selectedMBTI != null && selectedMBTI!.length == length) {
                    chars = selectedMBTI!.split('');
                  } else {
                    chars = List.generate(length, (_) => '_');
                  }
                  chars[groupIndex] = option;
                  final newVal = chars.join();
                  setState(() {
                    selectedMBTI = newVal;
                  });
                  widget.onSelected(newVal);
                },
                child: Text(option, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
          );
        }).toList()
      ],
    );
  }
}
