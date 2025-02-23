/// ---------------------------------------------------------------------------
/// 이 파일은 사용자가 체크리스트를 작성할 수 있는 UI를 구성합니다.
/// - PageView를 이용해 여러 페이지의 체크리스트 질문을 표시
/// - 각 질문에 대해 사용자의 응답을 수집하고, 응답값을 검증합니다.
/// - 최종적으로, 체크리스트 데이터 저장은 ChecklistService를 통해 백엔드로 위임합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:findmate1/service/tabs/matching/checklist_item.dart';
import 'package:findmate1/service/tabs/matching/checklist_service.dart'; // 나중에 서비스 호출

class ChecklistScreen extends StatefulWidget {
  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Map<String, dynamic> responses = {};

  bool _isPageComplete(List<ChecklistQuestion> questions) {
    for (var q in questions) {
      if (responses[q.id] == null) return false;
      if (q.type == "mbti") {
        List<dynamic> mbtiAns = responses[q.id];
        if (mbtiAns.length != 4 || mbtiAns.any((element) => element == null))
          return false;
      }
      if (q.type == "button" && (q.question.contains("잠버릇") || q.question.contains("샤워시간"))) {
        var answer = responses[q.id];
        if (answer is List && answer.isEmpty) return false;
      }
    }
    return true;
  }

  bool _isQuestionUnlocked(List<ChecklistQuestion> questions, int index) {
    for (int i = 0; i < index; i++) {
      if (responses[questions[i].id] == null) return false;
    }
    return true;
  }

  List<String> getRoomTypeOptions() {
    String? dorm = responses["dorm"];
    if (dorm == "제1생활관") {
      return ["2인실", "3인실"];
    } else if (dorm == "제2생활관" || dorm == "제3생활관") {
      return ["2인실", "4인실"];
    }
    return [];
  }

  void _onNextPage() {
    List<ChecklistQuestion> questions = checklistPages[_currentPage];
    if (!_isPageComplete(questions)) {
      _showIncompleteDialog();
      return;
    }
    if (_currentPage < checklistPages.length - 1) {
      setState(() { _currentPage++; });
      _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onPrevPage() {
    if (_currentPage > 0) {
      setState(() { _currentPage--; });
      _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onComplete() async {
    List<ChecklistQuestion> questions = checklistPages[_currentPage];
    if (!_isPageComplete(questions)) {
      _showIncompleteDialog();
      return;
    }
    // UI에서는 서비스 클래스를 호출하여 저장
    await ChecklistService.saveChecklist(responses);
    Navigator.pop(context, true);
  }

  void _showIncompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('경고'),
        content: Text('모든 항목을 입력해주세요.'),
        actions: [ TextButton(onPressed: () => Navigator.pop(context), child: Text('확인')) ],
      ),
    );
  }

  // (이하 picker, time, MBTI 등 선택 UI 구현은 기존 코드와 동일)
  // 예시로 하나의 위젯만 표시:
  Widget _buildQuestionWidget(ChecklistQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.question, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // 예시: 버튼 누르면 간단하게 응답 저장
            setState(() { responses[question.id] = "예시 응답"; });
          },
          child: Text(responses[question.id] ?? "선택"),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('체크리스트 작성')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: checklistPages.length,
              onPageChanged: (index) => setState(() { _currentPage = index; }),
              itemBuilder: (context, pageIndex) {
                List<ChecklistQuestion> questions = checklistPages[pageIndex];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: questions
                        .asMap()
                        .entries
                        .map((entry) {
                      int idx = entry.key;
                      ChecklistQuestion question = entry.value;
                      if (question.id == "roomType") {
                        question = ChecklistQuestion(
                          id: "roomType",
                          question: "인실",
                          type: "button",
                          options: getRoomTypeOptions(),
                        );
                      }
                      if (!_isQuestionUnlocked(questions, idx)) return SizedBox.shrink();
                      return _buildQuestionWidget(question);
                    })
                        .toList(),
                  ),
                );
              },
            ),
          ),
          // 페이지 인디케이터 및 네비게이션 버튼 (생략)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ElevatedButton(onPressed: _onPrevPage, child: Text('이전')),
              ElevatedButton(
                onPressed: _currentPage < checklistPages.length - 1 ? _onNextPage : _onComplete,
                child: Text(_currentPage < checklistPages.length - 1 ? '다음' : '완료'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
