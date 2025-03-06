// lib/widgets/checklist_widgets.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:findmate1/service/tabs/matching/checklist/checklist_item.dart';
import 'package:findmate1/service/tabs/matching/checklist/checklist_provider.dart';

/// (1) CupertinoPickerWidget
///     - showerDuration, alcoholAmount => 첫번째(0)
///     - 그 외(예: 학번, 생년) => 마지막에서부터 시작
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

    if (currentValue != null && currentValue is String && options.contains(currentValue)) {
      // 이미 저장된 값이 있으면 그 인덱스
      selectedIndex = options.indexOf(currentValue);
    } else {
      // 저장된 값이 없으면 index 결정
      if (options.isNotEmpty) {
        if (widget.question.id == "showerDuration" ||
            widget.question.id == "alcoholAmount") {
          // 샤워소요시간, 주량 => 첫번째(0)
          selectedIndex = 0;
        } else {
          // 생년, 학번 등 => 마지막 값
          selectedIndex = options.length - 1;
        }
      }
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
          style: TextStyle(fontSize:  18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (_) => Container(
                height: 300,
                color: Colors.white,
                child: Column(
                  children: [
                    // 확인/취소
                    Container(
                      height: 50,
                      color: Colors.grey.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            child: Text("취소"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoButton(
                            child: Text("확인"),
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
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedIndex,
                        ),
                        backgroundColor: Colors.white,
                        itemExtent: 30,
                        onSelectedItemChanged: (idx) {
                          setState(() => selectedIndex = idx);
                        },
                        children: options
                            .map((e) => Center(child: Text(e)))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(12),
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

/// (2) ButtonSelectionWidget: 성별, 생활관, 인실, 잠버릇(복수)
class ButtonSelectionWidget extends StatefulWidget {
  final ChecklistQuestion question;
  final Function(dynamic) onSelected;

  const ButtonSelectionWidget({
    Key? key,
    required this.question,
    required this.onSelected,
  }) : super(key: key);

  @override
  _ButtonSelectionWidgetState createState() => _ButtonSelectionWidgetState();
}

class _ButtonSelectionWidgetState extends State<ButtonSelectionWidget> {
  // multiSelect => List<String>, single => String
  dynamic selectedValue;

  // ★ 신입생이 "제3생활관" 외 선택시 표시할 오류문구
  String? dormErrorMessage;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChecklistProvider>(context, listen: false);
    final currentVal = provider.checklistAnswers[widget.question.id];

    if (widget.question.multiSelect) {
      if (currentVal is List<String>) {
        selectedValue = List<String>.from(currentVal);
      } else {
        selectedValue = <String>[];
      }
    } else {
      selectedValue = currentVal as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);
    final List<String> options =
        (widget.question.options as List?)?.cast<String>() ?? [];

    // ★ 학번 => 신입생인지 판단
    final yearOptions = generateStudentYearOptions();
    final lastYear = yearOptions.isNotEmpty ? yearOptions.last : null;
    final selectedYear = provider.checklistAnswers["studentYear"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 질문 제목
        Row(
          children: [
            Text(
              widget.question.question,
              style: TextStyle(fontSize:  18, fontWeight: FontWeight.bold),
            ),
            // 신입생이 dormError => 메시지 표시
            if (widget.question.id == "dorm" && dormErrorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  dormErrorMessage!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
          ],
        ),
        SizedBox(height: 8),

        // 버튼들
        Wrap(
          spacing: 8,
          children: options.map((option) {
            bool isSelected = false;
            if (widget.question.multiSelect) {
              isSelected = (selectedValue as List<String>).contains(option);
            } else {
              isSelected = (selectedValue == option);
            }

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                // 만약 dorm 질문이고, 신입생이면 => "제3생활관" 외는 선택 불가
                if (widget.question.id == "dorm" &&
                    lastYear != null &&
                    selectedYear == lastYear &&
                    option != "제3생활관") {
                  // 에러 표시 => "신입생은 제3생활관만 이용가능합니다."
                  setState(() {
                    dormErrorMessage = "신입생은 제3생활관만 이용 가능합니다.";
                  });
                  return; // 실제로는 선택 안 됨
                }

                // 잠버릇 '없음' 로직
                if (widget.question.multiSelect && widget.question.id == "sleepHabit") {
                  setState(() {
                    if (option == "없음") {
                      // '없음' 누르면 다른거 해제
                      selectedValue.clear();
                      selectedValue.add("없음");
                    } else {
                      // 다른거 누르면 '없음' 제거
                      if ((selectedValue as List<String>).contains("없음")) {
                        (selectedValue as List<String>).remove("없음");
                      }
                      // toggle
                      if ((selectedValue as List<String>).contains(option)) {
                        (selectedValue as List<String>).remove(option);
                      } else {
                        (selectedValue as List<String>).add(option);
                      }
                    }
                  });
                  widget.onSelected(selectedValue);
                  return;
                }

                // 일반 multiSelect
                if (widget.question.multiSelect) {
                  setState(() {
                    if ((selectedValue as List<String>).contains(option)) {
                      (selectedValue as List<String>).remove(option);
                    } else {
                      (selectedValue as List<String>).add(option);
                    }
                  });
                  widget.onSelected(selectedValue);
                  return;
                }

                // 단일
                setState(() {
                  selectedValue = option;
                  // dorm => 에러문구 해제
                  if (widget.question.id == "dorm") {
                    dormErrorMessage = null;
                  }
                });
                widget.onSelected(selectedValue);
              },
              child: Text(option, style: TextStyle(color: Colors.white)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// (3) TimePickerWidget: 기상/취침 시간
class TimePickerWidget extends StatelessWidget {
  final ChecklistQuestion question;
  final Function(String) onSelected;

  const TimePickerWidget({
    Key? key,
    required this.question,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);
    final currentVal = provider.checklistAnswers[question.id];
    final displayText = currentVal is String ? currentVal : "시간 선택";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.question, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              onSelected(pickedTime.format(context));
            }
          },
          child: Text(displayText),
        ),
      ],
    );
  }
}

/// (4) TextInputWidget: 단답형
class TextInputWidget extends StatefulWidget {
  final ChecklistQuestion question;
  final Function(String) onChanged;

  const TextInputWidget({
    Key? key,
    required this.question,
    required this.onChanged,
  }) : super(key: key);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChecklistProvider>(context, listen: false);
    final currentVal = provider.checklistAnswers[widget.question.id];
    _controller = TextEditingController(text: currentVal ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.question, // 예: "하고 싶은 말"
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: (val) => widget.onChanged(val),
          // 자동 줄바꿈 + 기본 높이 확대
          maxLines: 6,   // 원하는 만큼 늘려 높이 확보
          minLines: 1,   // 최소 1줄
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            // 넓은 힌트 문구 예시
            hintText: '예) 같이 지낼 때 꼭 지켜줬으면 하는 점, 본인 성격 등 자유롭게 작성하세요.',
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

/// (5) MBTISelectionWidget: 2차원 배열
class MBTISelectionWidget extends StatefulWidget {
  final ChecklistQuestion question;
  final Function(String) onSelected;

  const MBTISelectionWidget({
    Key? key,
    required this.question,
    required this.onSelected,
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
        Text(widget.question.question,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        // 각 그룹 I/E, S/N, F/T, P/J
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
                child: Text(option, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
          );
        }).toList()
      ],
    );
  }
}
