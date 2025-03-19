// lib/service/tabs/matching/checklist/checklist_provider.dart

import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/checklist/checklist_item.dart';
import 'package:findmate1/widgets/checklist_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChecklistProvider extends ChangeNotifier {
  /// 사용자의 체크리스트 응답들 (각 질문별 응답)
  Map<String, dynamic> checklistAnswers = {};

  /// 사용자가 선택한 우선순위 항목의 ID 리스트 (최대 3개)
  List<String> prioritySelection = [];

  /// 각 우선순위 항목에 대해 사용자가 선호하는 옵션 (예: {'alarm': '시끄러운'})
  Map<String, String> priorityPreferences = {};

  /// UI에서 SnackBar 등 출력에 사용할 컨텍스트 (옵션)
  BuildContext? globalContext;

  final Map<String, List<String>> _dormRoomMap = {
    "제1생활관": ["2인실", "3인실"],
    "제2생활관": ["2인실", "4인실"],
    "제3생활관": ["2인실", "4인실"],
  };

  /// Firestore에서 기존 체크리스트 데이터를 불러와 Provider에 반영
  Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('checklists').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey("priority") && data["priority"] is List) {
        prioritySelection = List<String>.from(data["priority"]);
        data.remove("priority");
      }
      if (data.containsKey("priorityPreferences") && data["priorityPreferences"] is Map) {
        priorityPreferences = Map<String, String>.from(data["priorityPreferences"]);
        data.remove("priorityPreferences");
      }
      checklistAnswers = data;
      notifyListeners();
    }
  }

  /// 전체 체크리스트 단계 수 반환 (checklistPages는 checklist_item.dart에 정의됨)
  int getTotalSteps() => checklistPages.length;

  /// 현재 페이지의 모든 질문이 응답되었는지 확인
  bool isStepComplete(int step) {
    for (var question in checklistPages[step]) {
      final answer = checklistAnswers[question.id];
      if (question.multiSelect) {
        if (answer == null || (answer is List && answer.isEmpty)) {
          return false;
        }
      } else {
        if (answer == null) {
          return false;
        }
      }
    }
    return true;
  }

  /// 특정 질문이 응답되었는지 확인
  bool isAnswered(String questionId) {
    final val = checklistAnswers[questionId];
    final question = _findQuestionById(questionId);
    if (question != null && question.multiSelect) {
      return val is List && val.isNotEmpty;
    }
    return (val != null);
  }

  /// 응답 업데이트 (특정 질문의 답변 변경)
  void updateAnswer(String id, dynamic value) {
    checklistAnswers[id] = value;
    // 만약 "dorm"이 선택되면 "roomType" 초기화
    if (id == "dorm") {
      checklistAnswers["roomType"] = null;
    }
    notifyListeners();
  }

  /// 사용자가 선택한 우선순위 항목 업데이트 (최대 3개)
  void updatePrioritySelection(List<String> selectedPriorities) {
    if (selectedPriorities.length > 3) return;
    prioritySelection = selectedPriorities;
    // 선택 해제된 항목이 있으면 해당 우선순위 선호 옵션도 삭제
    priorityPreferences.removeWhere((key, value) => !prioritySelection.contains(key));
    notifyListeners();
  }

  /// 특정 우선순위 항목에 대해 사용자가 선택한 선호 옵션 업데이트
  void updatePriorityPreference(String priorityId, String selectedOption) {
    priorityPreferences[priorityId] = selectedOption;
    notifyListeners();
  }

  /// Firestore에 체크리스트 저장 (체크리스트 응답 + 우선순위 관련 정보)
  Future<void> saveChecklist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dataToSave = {
        ...checklistAnswers,
        "priority": prioritySelection,
        "priorityPreferences": priorityPreferences,
      };
      await FirebaseFirestore.instance
          .collection('checklists')
          .doc(user.uid)
          .set(dataToSave, SetOptions(merge: true));
    }
  }

  /// 특정 질문 ID로 질문 찾기
  ChecklistQuestion? _findQuestionById(String questionId) {
    for (var page in checklistPages) {
      for (var q in page) {
        if (q.id == questionId) return q;
      }
    }
    return null;
  }

  /// 기존 체크리스트 위젯들을 생성하는 메서드
  List<Widget> buildChecklistWidgets(int step, BuildContext context, {bool readOnly = false, bool showAll = false}) {
    globalContext = context;
    final questions = checklistPages[step];
    List<Widget> widgets = [];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];

      // roomType (인실)인 경우: 생활관 선택에 따라 옵션 업데이트
      if (question.id == "roomType") {
        final dormVal = checklistAnswers["dorm"];
        if (dormVal != null) {
          final newRoomTypes = _dormRoomMap[dormVal] ?? [];
          question.options.clear();
          question.options.addAll(newRoomTypes);
        }
      }

      Widget questionWidget;
      switch (question.type) {
        case "picker":
          questionWidget = CupertinoPickerWidget(
            question: question,
            onSelected: (value) => updateAnswer(question.id, value),
          );
          break;
        case "button":
          questionWidget = ButtonSelectionWidget(
            question: question,
            selectedValue: checklistAnswers[question.id],
            onSelected: (value) => updateAnswer(question.id, value),
          );
          break;
        case "timeIos":
          final storedVal = checklistAnswers[question.id] as String?;
          final initialTime = _parseTimeString(storedVal);
          questionWidget = CupertinoTimePickerWidget(
            title: question.question,
            initialTime: initialTime,
            onTimeSelected: (selectedDateTime) {
              final formatted = _formatTimeString(selectedDateTime);
              updateAnswer(question.id, formatted);
            },
          );
          break;
        case "input":
          questionWidget = TextInputWidget(
            question: question,
            initialValue: checklistAnswers[question.id] ?? "",
            onChanged: (value) => updateAnswer(question.id, value),
          );
          break;
        case "mbti":
          questionWidget = MBTISelectionWidget(
            question: question,
            selectedValue: checklistAnswers[question.id],
            onSelected: (value) => updateAnswer(question.id, value),
          );
          break;
        default:
          questionWidget = Container();
          break;
      }

      if (readOnly) {
        questionWidget = IgnorePointer(child: questionWidget);
      }

      widgets.add(questionWidget);

      if (i < questions.length - 1) {
        widgets.add(const SizedBox(height: 24));
        widgets.add(const Divider(color: Colors.grey, thickness: 0.5, height: 20));
      }

      if (!showAll && !isAnswered(question.id)) {
        break;
      }
    }
    return widgets;
  }

  /// 우선순위 선택 UI를 빌드하는 위젯 리스트 반환
  List<Widget> buildPrioritySelectionWidget(BuildContext context) {
    // 후보 우선순위 항목 ID (원하는 항목으로 수정 가능)
    final List<String> candidatePriorities = [
      'studentYear',
      'wakeUpTime',
      'sleepTime',
      'alarm',
      'sleepHabit',
      'showerTime',
    ];

    List<Widget> widgets = [];

    widgets.add(
      Text(
        "우선순위 항목 선택 (최대 3개)",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );

    widgets.add(
      Wrap(
        spacing: 8.0,
        children: candidatePriorities.map((id) {
          final isSelected = prioritySelection.contains(id);
          return ChoiceChip(
            label: Text(id),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                if (prioritySelection.length < 3) {
                  prioritySelection.add(id);
                }
              } else {
                prioritySelection.remove(id);
                priorityPreferences.remove(id);
              }
              notifyListeners();
            },
          );
        }).toList(),
      ),
    );

    // 각 선택된 우선순위에 대해, checklist_item에 정의된 해당 질문의 options를 활용하여 선호 옵션 드롭다운 추가
    for (String priorityId in prioritySelection) {
      final question = _findQuestionById(priorityId);
      List<String> options = [];
      if (question != null && question.options != null && question.options is List) {
        try {
          options = List<String>.from(question.options);
        } catch (e) {
          options = [];
        }
      }
      widgets.add(const SizedBox(height: 16));
      widgets.add(
        Text(
          "우선순위 ($priorityId) 선호 옵션 선택",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
      widgets.add(
        DropdownButton<String>(
          value: priorityPreferences[priorityId],
          hint: const Text("옵션 선택"),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              updatePriorityPreference(priorityId, value);
            }
          },
        ),
      );
    }

    return widgets;
  }

  // 추가: 문자열 -> DateTime 변환 (예: "08:00" -> DateTime)
  DateTime _parseTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return DateTime(2023, 1, 1, 8, 0);
    }
    final parts = timeStr.split(":");
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      return DateTime(2023, 1, 1, hour, minute);
    }
    return DateTime(2023, 1, 1, 8, 0);
  }

  // 추가: DateTime -> 문자열 변환 (예: DateTime -> "08:00")
  String _formatTimeString(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
