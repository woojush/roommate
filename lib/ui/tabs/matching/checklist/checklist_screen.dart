// lib/ui/tabs/matching/checklist/checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:findmate1/service/tabs/matching/checklist_item.dart';
import 'package:findmate1/service/tabs/matching/checklist_provider.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';
import 'package:findmate1/service/tabs/matching/checklist_service.dart';

class ChecklistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        // ChangeNotifier를 상속받은 클래스의 상태 변화를 지속적으로 체크하고,
        // 상태가 변경될 때 UI를 자동으로 업데이트해주는 역할
      create: (_) => ChecklistProvider(), // ChangeNotifier를 상속받은 클래스 (상태변화 감지됨)
      child: ChecklistPageView(), // ChecklistProvider의 상태 변화에 따라 자동으로 업데이트되는 UI
      // notifyListeners()는 setState()와 비슷한 역할을 하지만, 전역적인 상태 관리를 가능하게 한다는 차이가 있어.
      // setState()는 특정 StatefulWidget 내부에서만 작동하는 반면,
      // notifyListeners()는 Provider를 구독하는 모든 위젯에서 상태 변화를 감지하고 UI를 업데이트해줌.
    );
  }
}

class ChecklistPageView extends StatefulWidget {
  @override
  _ChecklistPageViewState createState() => _ChecklistPageViewState();
}

class _ChecklistPageViewState extends State<ChecklistPageView> {
  final PageController _pageController = PageController();
  //PageView 위젯을 제어하는 역할.
  // PageController를 사용하면 특정 페이지로 이동하거나 애니메이션을 적용할 수 있음
  final _auth = FirebaseAuth.instance; // FirebaseAuth.instance 사용 쉽게.

  int _currentPage = 0; // 페이지는 0부터 시작.


  /// "다음" 버튼 누를 때의 로직
  Future<void> _onNext(BuildContext context) async {
    // 사용자가 체크리스트를 모두 입력했는지 확인한 후,
    // 마지막 페이지라면 Firestore에 저장하고,
    // 그렇지 않으면 다음 페이지로 이동

    final provider = Provider.of<ChecklistProvider>(context, listen: false);

    if (!provider.isStepComplete(_currentPage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 항목을 입력해야 다음으로 넘어갈 수 있습니다.')),
      );
      return;
    }

    if (_currentPage == checklistPages.length - 1) {
      // _currentPage가 checklistPages.length - 1이면 마지막 페이지에 도달한 것.
      await ChecklistService.saveChecklist(provider.checklistAnswers); // ✅ Firestore 저장 함수 호출
      //provider.checklistAnswers → 사용자가 입력한 체크리스트 데이터를 가져옴.
      // ✔ ChecklistService.saveChecklist(provider.checklistAnswers) 호출하여 Firestore에 저장.
      // ✔ await를 사용하여 Firestore 저장이 완료될 때까지 기다림.
      Navigator.pop(context, true);
    } else {
      setState(() {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          //부드러운 애니메이션 효과를 적용하며 다음 페이지로 이동.
        );
      });
    }
  }

  void _onPrevious() {
    // 이전 페이지로 이동
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
    //dispose()는 Dart의 StatefulWidget에서 이미 정의되어 있는 메서드이며,
    // 우리가 void dispose() 안에서 _pageController.dispose();를 호출함으로써,
    // 위젯이 더 이상 화면에 존재하지 않을 때(dispose()가 자동 호출될 때)
    // PageController의 리소스를 해제하는 역할을 한다.
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);

    return Scaffold(
      appBar:  SubScreenAppBar(title: '체크리스트 작성'),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // 사용자가 직접 스크롤하여 페이지 넘기는 것 방지.
              itemCount: checklistPages.length, // 페이지 개수는 checklistPages의 길이만큼.
              itemBuilder: (context, pageIndex) {
                return SingleChildScrollView( //화면이 넘칠 경우 스크롤 가능하도록 함
                  padding: EdgeInsets.all(16.0), // 모든 방향에 16px의 여백을 추가하여 디자인을 더 깔끔하게 정리.
                  child: Column( // 질문 위젯들을 수직으로 배치
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: provider.buildChecklistWidgets(pageIndex, context),
                    //현재 pageIndex에 해당하는 체크리스트 질문들을 가져와 Column 위젯 내부에 추가하는 역할을 한다.
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
                  child: Text('이전', style: boldTextStyle(color: Colors.white)),
                )
                    : SizedBox(width: 80), // ✅ 버튼 공간 확보 (이전 버튼이 없을 때도 균형 유지)

                Spacer(),

                Text(
                  '${_currentPage + 1}/${checklistPages.length}',
                  style: boldTextStyle(color: Colors.black),
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
                      style: boldTextStyle(color: Colors.white),
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

TextStyle boldTextStyle({double fontSize = 15, Color color = Colors.black}) {
  // 두꺼운 글씨 자주 사용하길래 볼드 스타일 하나 만들어놓음.
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
    color: color,
  );
}


