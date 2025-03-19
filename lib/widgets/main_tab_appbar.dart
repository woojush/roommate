import 'package:flutter/material.dart';

class MainTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;           // 첫 번째 탭(혹은 기본 제목)
  final String? subTitle;       // 두 번째 탭 (null이면 탭이 하나만 표시)
  final int selectedTabIndex;   // 선택된 탭 (0 또는 1)
  final Function(int)? onTabChanged; // 탭 선택 시 호출되는 콜백
  final List<Widget>? actions;  // 우측 상단 버튼 (옵션)

  const MainTabAppBar({
    Key? key,
    required this.title,
    this.subTitle,
    this.selectedTabIndex = 0,
    this.onTabChanged,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final bool hasTwoTabs = (subTitle != null && subTitle!.isNotEmpty);

    return SizedBox(
      height: preferredSize.height,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 좌측: 탭 텍스트 (버튼 역할)
              if (!hasTwoTabs)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )
              else
                Row(
                  children: [
                    // 첫 번째 탭
                    GestureDetector(
                      onTap: () {
                        if (onTabChanged != null) {
                          onTabChanged!(0);
                        }
                      },
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: selectedTabIndex == 0
                              ? Colors.black  // 선택됨
                              : Colors.grey.shade400, // 미선택
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 두 번째 탭
                    GestureDetector(
                      onTap: () {
                        if (onTabChanged != null) {
                          onTabChanged!(1);
                        }
                      },
                      child: Text(
                        subTitle!,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: selectedTabIndex == 1
                              ? Colors.black
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              // 우측: 액션 버튼 영역 (옵션)
              if (actions != null)
                Row(
                  children: actions!
                      .map(
                        (action) => Transform.translate(
                      offset: const Offset(0, -5),
                      child: action,
                    ),
                  )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
