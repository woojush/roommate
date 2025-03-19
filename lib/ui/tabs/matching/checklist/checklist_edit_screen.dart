// lib/ui/tabs/matching/checklist/checklist_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findmate1/service/tabs/matching/checklist/checklist_provider.dart';
import 'package:findmate1/service/tabs/matching/checklist/checklist_item.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';

class ChecklistEditScreen extends StatefulWidget {
  const ChecklistEditScreen({Key? key}) : super(key: key);

  @override
  _ChecklistEditScreenState createState() => _ChecklistEditScreenState();
}

class _ChecklistEditScreenState extends State<ChecklistEditScreen> {
  bool _isEditMode = false;
  bool _isLoading = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 초기 체크리스트 데이터를 Firestore에서 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ChecklistProvider>();
      await provider.loadFromFirestore();
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _onNext(BuildContext context) async {
    final provider = context.read<ChecklistProvider>();
    if (!provider.isStepComplete(_currentPage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해야 다음으로 넘어갈 수 있습니다.')),
      );
      return;
    }
    if (_currentPage == provider.getTotalSteps() - 1) {
      // 마지막 페이지라면 저장 후 종료
      if (_isEditMode) {
        await provider.saveChecklist();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('체크리스트가 저장되었습니다.')),
        );
      }
      Navigator.pop(context, true);
    } else {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPrevious() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
      appBar: SubScreenAppBar(
        title: _isEditMode ? '체크리스트 수정' : '체크리스트 확인',
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            tooltip: _isEditMode ? '저장' : '수정',
            onPressed: () async {
              if (_isEditMode) {
                await provider.saveChecklist();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('체크리스트가 저장되었습니다.')),
                );
              }
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.getTotalSteps(),
              itemBuilder: (context, pageIndex) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 기존 체크리스트 질문 위젯들
                      ...provider.buildChecklistWidgets(pageIndex, context),
                      // 현재 페이지가 마지막 페이지(추가 메세지 페이지)라면 우선순위 선택 UI 추가
                      if (pageIndex == provider.getTotalSteps() - 1)
                        ...provider.buildPrioritySelectionWidget(context),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.grey, thickness: 0.7, height: 0),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentPage > 0
                    ? ElevatedButton(
                  onPressed: _onPrevious,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('이전'),
                )
                    : const SizedBox(width: 80),
                Text('${_currentPage + 1} / ${provider.getTotalSteps()}'),
                ElevatedButton(
                  onPressed: () => _onNext(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _currentPage == provider.getTotalSteps() - 1 ? '완료' : '다음',
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
