/// checklist_provider.dart
/// -------------------------------------
/// 사용자의 체크리스트 데이터 관리 및 우선순위 설정을 담당합니다.
/// -------------------------------------

import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/matching/checklist_item.dart';
import 'package:findmate1/widgets/checklist_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChecklistProvider extends ChangeNotifier {
  Map<String, dynamic> checklistAnswers = {}; // 키-값 쌍을 저장하는 자료구조 (Map)
  List<String> prioritySelection = []; // 사용자가 선택한 우선순위 3개
  BuildContext? globalContext; // UI에서 SnackBar 사용을 위한 컨텍스트 저장

  final Map<String, List<String>> _dormRoomMap = {
    // key: 생활관 이름, value : 인실
    "제1생활관": ["2인실", "3인실"],
    "제2생활관": ["2인실", "4인실"],
    "제3생활관": ["2인실", "4인실"],
  };

  //  현재 단계(페이지)가 모든 질문에 대해 응답이 완료되었는지 확인
  bool isStepComplete(int step) {
    for (var question in checklistPages[step]) { // question은 변화하는 checklistPages의 step값이 저장됨.
      final answer = checklistAnswers[question.id];
      // checklistAnswers는 Map<String, dynamic> 형태의 딕셔너리(Map).
      // 즉, checklistAnswers[question.id]는 question.id라는 키(key)로 저장된 값을 가져오는 것임.
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

  // 특정 질문이 응답되었는지 확인
  bool isAnswered(String questionId) {
    final val = checklistAnswers[questionId];
    final question = _findQuestionById(questionId);
    if (question != null && question.multiSelect) {
      return val is List && val.isNotEmpty;
    }
    return (val != null);
  }

  // 응답 업데이트 및 신입생 생활관 자동 설정
  void updateAnswer(String id, dynamic value) {
    checklistAnswers[id] = value;

    // 🟢 최신 학번(신입생) 선택 시, 자동으로 제3생활관 설정
    if (id == "studentYear") {
      List<String> studentYears = generateStudentYearOptions();
      String latestYear = studentYears.last;
      if (value == latestYear) {
        checklistAnswers["dorm"] = "제3생활관"; // 자동 선택
      }
    }

    // 🟢 신입생이 다른 생활관을 선택하려 하면 자동으로 다시 제3생활관으로 설정
    if (id == "dorm" && _isLatestStudentYear() && value != "제3생활관") {
      checklistAnswers["dorm"] = "제3생활관"; // 다시 고정
      Future.microtask(() {
        if (globalContext != null) {
          ScaffoldMessenger.of(globalContext!).showSnackBar(
            SnackBar(
              content: Text("신입생은 제3생활관만 이용 가능합니다."),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }

    // 🟢 만약 dorm 선택 → roomType 초기화
    if (id == "dorm") {
      checklistAnswers["roomType"] = null;
    }

    notifyListeners();
  }

  /// ✅ 사용자의 우선순위 항목 선택
  void updatePrioritySelection(List<String> selectedPriorities) {
    if (selectedPriorities.length > 3) {
      return; // 3개까지만 선택 가능
    }
    prioritySelection = selectedPriorities;
    notifyListeners();
  }

  /// ✅ Firestore에 체크리스트 저장
  Future<void> saveChecklist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('checklists').doc(user.uid).set({
        "checklist": checklistAnswers,
        "priority": prioritySelection,
      }, SetOptions(merge: true));
    }
  }

  /// ✅ 특정 단계의 질문을 위젯 리스트로 변환하여 반환
  List<Widget> buildChecklistWidgets(int step, BuildContext context) {
    globalContext = context; // SnackBar를 사용하기 위해 컨텍스트 저장
    final questions = checklistPages[step];
    List<Widget> widgets = [];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];

      // 🟢 생활관 → 인실 로직 (동적으로 변경)
      if (question.id == "roomType") {
        final dormVal = checklistAnswers["dorm"];
        if (dormVal != null) {
          final newRoomTypes = _dormRoomMap[dormVal] ?? [];
          question.options.clear();
          question.options.addAll(newRoomTypes);
        }
      }

      // 🟢 신입생이면 생활관 선택 버튼을 비활성화하고 안내 메시지만 표시
      if (question.id == "dorm" && _isLatestStudentYear()) {
        widgets.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("생활관", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("제3생활관 (신입생은 제3생활관만 이용 가능)", style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ));
        continue; // 선택 버튼을 표시하지 않음
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
            onSelected: (value) => updateAnswer(question.id, value),
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
      if (i < questions.length - 1) {
        widgets.add(SizedBox(height: 24));
      }

      if (!isAnswered(question.id)) {
        break;
      }
    }
    return widgets;
  }

  /// ✅ 특정 질문 ID로 질문을 찾음
  ChecklistQuestion? _findQuestionById(String questionId) {
    for (var page in checklistPages) {
      for (var q in page) {
        if (q.id == questionId) return q;
      }
    }
    return null;
  }

  /// ✅ 사용자가 선택한 학번이 최신 학번인지 확인
  bool _isLatestStudentYear() {
    List<String> studentYears = generateStudentYearOptions();
    String latestYear = studentYears.last;
    return checklistAnswers["studentYear"] == latestYear;
  }
}
