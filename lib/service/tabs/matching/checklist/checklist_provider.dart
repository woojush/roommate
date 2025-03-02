import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/checklist_item.dart';
import 'package:findmate1/widgets/checklist_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChecklistProvider extends ChangeNotifier {
  Map<String, dynamic> checklistAnswers = {}; // 사용자의 체크리스트 응답
  List<String> prioritySelection = []; // 사용자가 선택한 우선순위 3개
  BuildContext? globalContext; // UI에서 SnackBar 사용을 위한 컨텍스트 저장

  final Map<String, List<String>> _dormRoomMap = {
    // 생활관 이름별 인실 옵션
    "제1생활관": ["2인실", "3인실"],
    "제2생활관": ["2인실", "4인실"],
    "제3생활관": ["2인실", "4인실"],
  };

  /// [1] 현재 페이지(step)의 모든 질문이 응답되었는지 확인
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

  /// [2] 특정 질문이 응답되었는지 확인
  bool isAnswered(String questionId) {
    final val = checklistAnswers[questionId];
    final question = _findQuestionById(questionId);
    if (question != null && question.multiSelect) {
      return val is List && val.isNotEmpty;
    }
    return (val != null);
  }

  /// [3] 응답 업데이트 (신입생 관련 제약 기능 제거)
  void updateAnswer(String id, dynamic value) {
    checklistAnswers[id] = value;
    // 만약 "dorm"이 선택되면 "roomType"(인실) 초기화
    if (id == "dorm") {
      checklistAnswers["roomType"] = null;
    }
    notifyListeners();
  }

  /// [4] 사용자의 우선순위 항목 선택
  void updatePrioritySelection(List<String> selectedPriorities) {
    if (selectedPriorities.length > 3) return;
    prioritySelection = selectedPriorities;
    notifyListeners();
  }

  /// [5] Firestore에 체크리스트 저장
  Future<void> saveChecklist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('checklists').doc(user.uid).set({
        "checklist": checklistAnswers,
        "priority": prioritySelection,
      }, SetOptions(merge: true));
    }
  }

  /// [6] 현재 페이지의 질문을 위젯 리스트로 생성하여 반환
  List<Widget> buildChecklistWidgets(int step, BuildContext context) {
    globalContext = context; // SnackBar 등에 사용할 컨텍스트 저장
    final questions = checklistPages[step];
    List<Widget> widgets = [];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];

      // roomType(인실)일 경우: 생활관 선택 여부에 따라 옵션 업데이트
      if (question.id == "roomType") {
        final dormVal = checklistAnswers["dorm"];
        if (dormVal != null) {
          final newRoomTypes = _dormRoomMap[dormVal] ?? [];
          question.options.clear();
          question.options.addAll(newRoomTypes);
        }
      }
      // (특별 분기 없이, 모든 질문은 아래 switch-case로 통일 처리)

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
            onSelected: (value) => updateAnswer(question.id, value),
            // 버튼 선택 위젯 내부에서 타이틀 및 버튼 텍스트 스타일을
            // TextStyle(fontSize: 18, fontWeight: FontWeight.bold)로 통일하도록 수정합니다.
          );
          break;
        case "time":
          questionWidget = TimePickerWidget(
            question: question,
            onSelected: (value) => updateAnswer(question.id, value),
          );
          break;
        case "input":
          questionWidget = TextInputWidget(
            question: question,
            onChanged: (value) => updateAnswer(question.id, value),
          );
          break;
        case "mbti":
          questionWidget = MBTISelectionWidget(
            question: question,
            onSelected: (value) => updateAnswer(question.id, value),
          );
          break;
        default:
          questionWidget = Container();
      }

      widgets.add(questionWidget);

      // 질문 간 간격 및 Divider 추가 (모든 질문에 대해 동일하게)
      if (i < questions.length - 1) {
        widgets.add(SizedBox(height: 24));
        widgets.add(Divider(color: Colors.grey, thickness: 0.5, height: 20));
      }

      if (!isAnswered(question.id)) {
        break;
      }
    }
    return widgets;
  }

  /// [7] 특정 질문 ID로 질문 찾기
  ChecklistQuestion? _findQuestionById(String questionId) {
    for (var page in checklistPages) {
      for (var q in page) {
        if (q.id == questionId) return q;
      }
    }
    return null;
  }

  /// [8] 사용자가 선택한 학번이 최신 학번(신입생)인지 확인
  bool _isLatestStudentYear() {
    List<String> studentYears = generateStudentYearOptions();
    String latestYear = studentYears.last;
    return checklistAnswers["studentYear"] == latestYear;
  }
}
