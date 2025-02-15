// lib/tabs/info.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:findmate1/widgets/design.dart'; // CustomListTile 등 디자인 위젯

// 데이터를 담는 클래스들
class InfoItem {
  final String title;
  final String? link;
  final List<InfoItem> children;

  InfoItem({
    required this.title,
    this.link,
    this.children = const [],
  });
}

class InfoCategory {
  final String title;
  final List<InfoItem> items;

  InfoCategory({
    required this.title,
    required this.items,
  });
}

/// URL을 Safari 기반 브라우저(SFSafariViewController)로 여는 함수
Future<void> openInSafari(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView, // iOS에서 SFSafariViewController 사용
    );
  } else {
    throw 'Could not launch $urlString';
  }
}

/// 기숙사 정보 메인 화면
class Info extends StatelessWidget {
  final List<InfoCategory> categories = [
    InfoCategory(
      title: '공지사항 및 자료실',
      items: [
        InfoItem(
          title: '공지사항',
          link: 'https://www.gachon.ac.kr/dormitory/2351/subview.do',
        ),
        InfoItem(
          title: '자료실',
          link: 'https://www.gachon.ac.kr/dormitory/2352/subview.do',
        ),
      ],
    ),
    InfoCategory(
      title: '시설 안내',
      items: [
        InfoItem(
          title: '제1학생생활관',
          children: [
            InfoItem(
              title: '수용현황',
              link: 'https://www.gachon.ac.kr/dormitory/2366/subview.do',
            ),
            InfoItem(
              title: '호실/시설안내',
              link: 'https://www.gachon.ac.kr/dormitory/2367/subview.do',
            ),
            InfoItem(
              title: '전화번호 안내',
              link: 'https://www.gachon.ac.kr/dormitory/2368/subview.do',
            ),
          ],
        ),
        InfoItem(
          title: '제2학생생활관',
          children: [
            InfoItem(
              title: '수용현황',
              link: 'https://www.gachon.ac.kr/dormitory/2369/subview.do',
            ),
            InfoItem(
              title: '호실/시설안내',
              link: 'https://www.gachon.ac.kr/dormitory/2370/subview.do',
            ),
            InfoItem(
              title: '전화번호 안내',
              link: 'https://www.gachon.ac.kr/dormitory/2371/subview.do',
            ),
          ],
        ),
        InfoItem(
          title: '제3학생생활관',
          children: [
            InfoItem(
              title: '수용현황',
              link: 'https://www.gachon.ac.kr/dormitory/9347/subview.do',
            ),
            InfoItem(
              title: '호실/시설안내',
              link: 'https://www.gachon.ac.kr/dormitory/9348/subview.do',
            ),
            InfoItem(
              title: '전화번호 안내',
              link: 'https://www.gachon.ac.kr/dormitory/9349/subview.do',
            ),
          ],
        ),
      ],
    ),
    InfoCategory(
      title: '생활관 안내 및 수칙, 편의시설',
      items: [
        InfoItem(title: '생활관 이용안내', link: ''),
        InfoItem(
          title: '생활관 수칙',
          children: [
            InfoItem(
              title: '상점기준표',
              link: 'https://www.gachon.ac.kr/dormitory/7747/subview.do',
            ),
            InfoItem(
              title: '벌점기준표',
              link: 'https://www.gachon.ac.kr/dormitory/7748/subview.do',
            ),
          ],
        ),
        InfoItem(
          title: '제1학생생활관 편의시설',
          children: [
            InfoItem(
              title: '출입시스템이용',
              link: 'https://www.gachon.ac.kr/dormitory/7749/subview.do',
            ),
            InfoItem(
              title: '카드키사용/호실전기사용',
              link: 'https://www.gachon.ac.kr/dormitory/7750/subview.do',
            ),
            InfoItem(
              title: '네트워크/인터넷',
              link: 'https://www.gachon.ac.kr/dormitory/7751/subview.do',
            ),
            InfoItem(
              title: '냉난방시설',
              link: 'https://www.gachon.ac.kr/dormitory/7752/subview.do',
            ),
            InfoItem(
              title: '휴게실/탕비실 이용',
              link: 'https://www.gachon.ac.kr/dormitory/7753/subview.do',
            ),
            InfoItem(
              title: '코인세탁실 이용',
              link: 'https://www.gachon.ac.kr/dormitory/7754/subview.do',
            ),
            InfoItem(
              title: '다리미 이용',
              link: 'https://www.gachon.ac.kr/dormitory/7755/subview.do',
            ),
            InfoItem(
              title: '우편물수령/택배수령',
              link: 'https://www.gachon.ac.kr/dormitory/7756/subview.do',
            ),
            InfoItem(
              title: '외부인 방문',
              link: 'https://www.gachon.ac.kr/dormitory/7757/subview.do',
            ),
            InfoItem(
              title: '비상응급 연락처',
              link: 'https://www.gachon.ac.kr/dormitory/7758/subview.do',
            ),
            InfoItem(
              title: '학생식당이용',
              link: 'https://www.gachon.ac.kr/dormitory/10117/subview.do',
            ),
          ],
        ),
        InfoItem(
          title: '제2학생생활관 편의시설',
          children: [
            InfoItem(
              title: '출입시스템이용',
              link: 'https://www.gachon.ac.kr/dormitory/7759/subview.do',
            ),
            InfoItem(
              title: '카드키사용/호실전기사용',
              link: 'https://www.gachon.ac.kr/dormitory/7760/subview.do',
            ),
            InfoItem(
              title: '네트워크/인터넷',
              link: 'https://www.gachon.ac.kr/dormitory/7761/subview.do',
            ),
            InfoItem(
              title: '냉난방시설',
              link: 'https://www.gachon.ac.kr/dormitory/7762/subview.do',
            ),
            InfoItem(
              title: '휴게실/탕비실 이용',
              link: 'https://www.gachon.ac.kr/dormitory/7763/subview.do',
            ),
            InfoItem(
              title: '코인세탁실 이용',
              link: 'https://www.gachon.ac.kr/dormitory/7764/subview.do',
            ),
            InfoItem(
              title: '다리미 이용',
              link: 'https://www.gachon.ac.kr/dormitory/7765/subview.do',
            ),
            InfoItem(
              title: '우편물수령/택배수령',
              link: 'https://www.gachon.ac.kr/dormitory/7766/subview.do',
            ),
            InfoItem(
              title: '외부인 방문',
              link: 'https://www.gachon.ac.kr/dormitory/7767/subview.do',
            ),
            InfoItem(
              title: '비상응급 연락처',
              link: 'https://www.gachon.ac.kr/dormitory/7768/subview.do',
            ),
            InfoItem(
              title: '학생식당이용',
              link: 'https://www.gachon.ac.kr/dormitory/7769/subview.do',
            ),
          ],
        ),
        InfoItem(
          title: '제3학생생활관 편의시설',
          children: [
            InfoItem(
              title: '출입시스템이용',
              link: 'https://www.gachon.ac.kr/dormitory/9351/subview.do',
            ),
            InfoItem(
              title: '카드키사용/호실전기사용',
              link: 'https://www.gachon.ac.kr/dormitory/9352/subview.do',
            ),
            InfoItem(
              title: '네트워크/인터넷',
              link: 'https://www.gachon.ac.kr/dormitory/9353/subview.do',
            ),
            InfoItem(
              title: '냉난방시설',
              link: 'https://www.gachon.ac.kr/dormitory/9354/subview.do',
            ),
            InfoItem(
              title: '휴게실/탕비실 이용',
              link: 'https://www.gachon.ac.kr/dormitory/9355/subview.do',
            ),
            InfoItem(
              title: '코인세탁실 이용',
              link: 'https://www.gachon.ac.kr/dormitory/9356/subview.do',
            ),
            InfoItem(
              title: '외부인 방문',
              link: 'https://www.gachon.ac.kr/dormitory/9357/subview.do',
            ),
            InfoItem(
              title: '비상응급 연락처',
              link: 'https://www.gachon.ac.kr/dormitory/9358/subview.do',
            ),
            InfoItem(
              title: '학생식당이용',
              link: 'https://www.gachon.ac.kr/dormitory/10118/subview.do',
            ),
          ],
        ),
      ],
    ),
    InfoCategory(
      title: '입.퇴사 안내',
      items: [
        InfoItem(
          title: '입사 안내',
          children: [
            InfoItem(
              title: '입사일정안내',
              link: 'https://www.gachon.ac.kr/dormitory/2372/subview.do',
            ),
            InfoItem(
              title: '선발안내 및 절차',
              link: 'https://www.gachon.ac.kr/dormitory/2373/subview.do',
            ),
            InfoItem(
              title: '생활관비 안내',
              link: 'https://www.gachon.ac.kr/dormitory/2374/subview.do',
            ),
          ],
        ),
        InfoItem(
          title: '퇴사 안내',
          children: [
            InfoItem(
              title: '입사일정안내',
              link: 'https://www.gachon.ac.kr/dormitory/2375/subview.do',
            ),
            InfoItem(
              title: '선발안내 및 절차',
              link: 'https://www.gachon.ac.kr/dormitory/2376/subview.do',
            ),
            InfoItem(
              title: '생활관비 안내',
              link: 'https://www.gachon.ac.kr/dormitory/2377/subview.do',
            ),
          ],
        ),
      ],
    ),
    InfoCategory(
      title: '생활관 소개',
      items: [
        InfoItem(
          title: '인삿말',
          link: 'https://www.gachon.ac.kr/dormitory/2337/subview.do',
        ),
        InfoItem(
          title: '설립목적',
          link: 'https://www.gachon.ac.kr/dormitory/2338/subview.do',
        ),
        InfoItem(
          title: '조직도',
          link: 'https://www.gachon.ac.kr/dormitory/2339/subview.do',
        ),
        InfoItem(
          title: '오시는길',
          link: 'https://www.gachon.ac.kr/dormitory/2340/subview.do',
        ),
      ],
    ),
  ];

  Info({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기숙사 정보')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ExpansionTile(
              // 메인 카테고리 타이틀 좌측 여백을 줄임
              tilePadding: const EdgeInsets.symmetric(horizontal: 0.0),
              title: Text(
                category.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // 기본 왼쪽 삼각형 아이콘 제거
              leading: const SizedBox.shrink(),
              children: category.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 25.0), // 서브 카테고리 항목들 추가 인덴트
                  child: CustomListTile(
                    title: item.title,
                    // 좌측 아이콘 제거 (null 전달)
                    icon: null,
                    trailing: const SizedBox.shrink(),
                    onTap: () {
                      if (item.link != null && item.link!.isNotEmpty) {
                        // Safari 기반 브라우저로 열기
                        openInSafari(item.link!);
                      } else if (item.children.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoListPage(
                              title: item.title,
                              items: item.children,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('링크가 없습니다.')),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

/// 세부 항목들을 보여주는 페이지 (InfoListPage)
class InfoListPage extends StatelessWidget {
  final String title;
  final List<InfoItem> items;
  const InfoListPage({Key? key, required this.title, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(left: 16.0), // 서브 항목 인덴트
            child: CustomListTile(
              title: item.title,
              // 좌측 아이콘 제거
              icon: null,
              trailing: const SizedBox.shrink(),
              onTap: () {
                if (item.link != null && item.link!.isNotEmpty) {
                  // Safari 기반 브라우저로 열기
                  openInSafari(item.link!);
                } else if (item.children.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoListPage(
                        title: item.title,
                        items: item.children,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('링크가 없습니다.')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/*
  ※ iOS SSL 에러(-1200) 해결 방법
  iOS의 App Transport Security 설정으로 인해 SSL 에러가 발생할 경우,
  ios/Runner/Info.plist 파일에 아래 설정을 추가하세요.

  <key>NSAppTransportSecurity</key>
  <dict>
      <key>NSAllowsArbitraryLoads</key>
      <true/>
  </dict>

  (개발 중에만 사용하고, 실제 배포 전에는 보안 도메인 예외를 설정하시기 바랍니다.)
*/
