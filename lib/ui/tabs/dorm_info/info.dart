// lib/ui/tabs/dorm_info/info.dart

import 'package:flutter/material.dart';
import 'package:findmate1/service/tabs/dorm_info/info_model.dart'; // InfoCategory, InfoItem 모델 임포트
import 'package:findmate1/service/tabs/dorm_info/info_service.dart'; // 백엔드 서비스
import 'package:findmate1/utils/url_launcher.dart'; // URL 열기 함수
import 'package:findmate1/widgets/main_tab_appbar.dart'; // AppBar

// -----------------------------------------------------------------------------
// CategoryContent 위젯: 각 카테고리의 내용을 토글(accordion) 형식으로 표시
// -----------------------------------------------------------------------------
class CategoryContent extends StatefulWidget {
  final InfoCategory category;

  // 탭 전환 시 상태 초기화를 위해 UniqueKey 사용
  const CategoryContent({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryContentState createState() => _CategoryContentState();
}

class _CategoryContentState extends State<CategoryContent> {
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = List<bool>.filled(widget.category.items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.category.items.asMap().entries.map((entry) {
        int index = entry.key;
        InfoItem item = entry.value;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          color: Colors.indigo,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            // 헤더를 고정 높이 Container로 감싸서 토글 유무와 상관없이 높이를 일정하게 함
            title: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  if (item.children.isNotEmpty)
                    Icon(
                      _isExpanded[index] ? Icons.arrow_drop_down : Icons.arrow_right,
                      size: 24,
                      color: Colors.white,
                    ),
                  if (item.children.isNotEmpty)
                    const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              setState(() {
                _isExpanded[index] = !_isExpanded[index];
                if (_isExpanded[index]) {
                  for (int i = 0; i < _isExpanded.length; i++) {
                    if (i != index) _isExpanded[i] = false;
                  }
                }
              });
              if (item.link != null && item.link!.isNotEmpty) {
                openInSafari(item.link!);
              }
            },
            subtitle: item.children.isNotEmpty
                ? AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item.children.map((childItem) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 40), // 하위 항목은 제목보다 오른쪽에 위치
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        childItem.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        if (childItem.link != null && childItem.link!.isNotEmpty) {
                          openInSafari(childItem.link!);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              crossFadeState: _isExpanded[index]
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// InfoListPage: 하위 항목들을 토글 형식으로 표시 (세부페이지)
// -----------------------------------------------------------------------------
class InfoListPage extends StatefulWidget {
  final String title;
  final List<InfoItem> items;

  const InfoListPage({Key? key, required this.title, required this.items})
      : super(key: key);

  @override
  _InfoListPageState createState() => _InfoListPageState();
}

class _InfoListPageState extends State<InfoListPage> {
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = List<bool>.filled(widget.items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            color: Colors.indigo,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Container(
                height: 48,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    if (item.children.isNotEmpty)
                      Icon(
                        _isExpanded[index] ? Icons.arrow_drop_down : Icons.arrow_right,
                        size: 16,
                        color: Colors.white,
                      ),
                    if (item.children.isNotEmpty)
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  _isExpanded[index] = !_isExpanded[index];
                  if (_isExpanded[index]) {
                    for (int i = 0; i < _isExpanded.length; i++) {
                      if (i != index) _isExpanded[i] = false;
                    }
                  }
                });
                if (item.link != null && item.link!.isNotEmpty) {
                  openInSafari(item.link!);
                }
              },
              subtitle: item.children.isNotEmpty
                  ? AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.children.map((childItem) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          childItem.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          if (childItem.link != null && childItem.link!.isNotEmpty) {
                            openInSafari(childItem.link!);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                crossFadeState: _isExpanded[index]
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 메인 화면: 탭과 UI 렌더링 (탭 전환 시 열린 토글은 UniqueKey로 상태 초기화)
// -----------------------------------------------------------------------------
class Info extends StatelessWidget {
  final InfoService infoService = InfoService();

  @override
  Widget build(BuildContext context) {
    final categories = infoService.fetchCategories();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: MainTabAppBar(title: '기숙사 정보'),
        body: Column(
          children: [
            Container(
              color: Colors.indigo,
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: categories.map((cat) => Tab(text: cat.title)).toList(),
              ),
            ),
            const SizedBox(height: 16), // 탭바와 토글 영역 사이 간격
            Expanded(
              child: TabBarView(
                // 각 탭의 CategoryContent에 UniqueKey를 부여해 탭 전환 시 상태 초기화
                children: categories
                    .map((cat) => CategoryContent(
                  key: UniqueKey(),
                  category: cat,
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
