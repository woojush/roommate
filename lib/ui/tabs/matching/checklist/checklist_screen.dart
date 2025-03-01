// lib/ui/tabs/matching/checklist/checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:findmate1/service/tabs/matching/checklist_item.dart';
import 'package:findmate1/service/tabs/matching/checklist_provider.dart';

class ChecklistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChecklistProvider(),
      child: ChecklistPageView(),
    );
  }
}

class ChecklistPageView extends StatefulWidget {
  @override
  _ChecklistPageViewState createState() => _ChecklistPageViewState();
}

class _ChecklistPageViewState extends State<ChecklistPageView> {
  final PageController _pageController = PageController();
  final _auth = FirebaseAuth.instance;

  int _currentPage = 0;

  /// 체크리스트를 최상위 컬렉션(`checklists`)에 저장
  Future<void> _saveChecklist(BuildContext context) async {
    final provider = Provider.of<ChecklistProvider>(context, listen: false);
    final answers = provider.checklistAnswers;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('checklists')
          .doc(user.uid)
          .set(
        {
          ...answers,
          'lastUpdate': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving checklist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('체크리스트 저장 중 오류가 발생했습니다.')),
      );
    }
  }

  /// "다음" 버튼 누를 때의 로직
  Future<void> _onNext(BuildContext context) async {
    final provider = Provider.of<ChecklistProvider>(context, listen: false);

    if (!provider.isStepComplete(_currentPage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 항목을 입력해야 다음으로 넘어갈 수 있습니다.')),
      );
      return;
    }

    if (_currentPage == checklistPages.length - 1) {
      await _saveChecklist(context);
      Navigator.pop(context, true);
    } else {
      setState(() {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _onPrevious() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('체크리스트 작성'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: checklistPages.length,
              itemBuilder: (context, pageIndex) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: provider.buildChecklistWidgets(pageIndex, context),
                  ),
                );
              },
            ),
          ),

          Divider(color: Colors.grey,thickness: 0.7,height: 0,),

          // 하단 버튼 + 페이지 표시
          Container(
            padding: EdgeInsets.fromLTRB(16, 5, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _currentPage > 0
                    ? ElevatedButton(
                  onPressed: _onPrevious,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // ✅ 버튼 배경색 (검은색)
                    foregroundColor: Colors.white, // ✅ 버튼 글씨색 (흰색)
                  ),
                  child: Text('이전'),
                )
                    : SizedBox(width: 80), // ✅ 버튼 공간 확보 (이전 버튼이 없을 때도 균형 유지)

                Spacer(),

                Text(
                  '${_currentPage + 1}/${checklistPages.length}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Spacer(),

                ElevatedButton(
                  onPressed: () => _onNext(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // 기본 버튼 색상 (파란색)
                    foregroundColor: Colors.white, // 버튼 글씨색 (흰색)
                  ),
                  child: Text(
                    _currentPage == checklistPages.length - 1 ? '완료' : '다음',
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
