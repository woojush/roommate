import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:url_launcher/url_launcher_string.dart';


class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  late Future<List<Map<String, String>>> futureNotices;
  int currentPage = 1; // ✅ 현재 페이지

  @override
  void initState() {
    super.initState();
    futureNotices = fetchNotices(currentPage);
  }

  // 🔹 공지사항 HTML 크롤링 함수 (페이지네이션 추가)
  Future<List<Map<String, String>>> fetchNotices(int page) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://www.gachon.ac.kr/dormitory/2351/subview.do?enc=Zm5jdDF8QEB8JTJGYmJzJTJGZG9ybWl0b3J5JTJGMzMwJTJGYXJ0Y2xMaXN0LmRvJTNG&page=$page'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        List<Map<String, String>> notices = [];

        // ✅ 공지사항 목록 가져오기
        document.querySelectorAll('tr').forEach((row) {
          var titleElement = row.querySelector('td.td-subject a strong');
          var linkElement = row.querySelector('td.td-subject a');
          var dateElement = row.querySelector('td.td-date');

          if (titleElement != null && linkElement != null && dateElement != null) {
            String title = titleElement.text.trim();
            String link = "https://www.gachon.ac.kr" + linkElement.attributes['href']!;
            String date = dateElement.text.trim();

            notices.add({
              'title': title,
              'link': link,
              'date': date,
            });
          }
        });

        return notices.isNotEmpty ? notices : [];
      } else {
        throw Exception('공지사항을 불러올 수 없습니다.');
      }
    } catch (e) {
      return [];
    }
  }

  // 🔹 페이지 변경 함수
  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
      futureNotices = fetchNotices(currentPage); // ✅ 새로운 페이지 데이터 로드
    });
  }

  // 🔹 공지사항 링크 열기
  Future<void> _openNotice(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'URL을 열 수 없습니다: $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기숙사 공지사항')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: futureNotices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류 발생: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('공지사항이 없습니다.'));
                }

                // 🔹 공지사항 리스트 UI
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var notice = snapshot.data![index];
                    return ListTile(
                      title: Text(notice['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('작성일: ${notice['date']}'),
                      leading: const Icon(Icons.article),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _openNotice(notice['link']!);
                      },
                    );
                  },
                );
              },
            ),
          ),
          // 🔹 페이지 이동 버튼 UI
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: currentPage > 1 ? () => changePage(currentPage - 1) : null, // ✅ 이전 페이지 이동
                ),
                Text('페이지 $currentPage'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => changePage(currentPage + 1), // ✅ 다음 페이지 이동
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
