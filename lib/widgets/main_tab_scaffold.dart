import 'package:flutter/material.dart';
import 'main_tab_appbar.dart';

class MainTabScaffold extends StatefulWidget {
  final String title;         // 첫 번째 탭 텍스트 (또는 기본 제목)
  final String? subTitle;     // 두 번째 탭 텍스트 (null이면 탭이 하나만 표시)
  final Widget firstTabBody;  // 첫 번째 탭 선택 시 보여줄 body
  final Widget? secondTabBody;// 두 번째 탭 선택 시 보여줄 body (옵션)
  final List<Widget>? actions; // 우측 액션 버튼

  const MainTabScaffold({
    Key? key,
    required this.title,
    this.subTitle,
    required this.firstTabBody,
    this.secondTabBody,
    this.actions,
  }) : super(key: key);

  @override
  _MainTabScaffoldState createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTabAppBar(
        title: widget.title,
        subTitle: widget.subTitle,
        selectedTabIndex: selectedTabIndex,
        onTabChanged: (int index) {
          setState(() {
            selectedTabIndex = index;
          });
        },
        actions: widget.actions,
      ),
      body: widget.subTitle == null || widget.secondTabBody == null
          ? widget.firstTabBody
          : selectedTabIndex == 0
          ? widget.firstTabBody
          : widget.secondTabBody!,
    );
  }
}
