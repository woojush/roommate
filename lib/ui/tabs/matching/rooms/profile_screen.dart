/// ---------------------------------------------------------------------------
/// 이 파일은 특정 사용자의 체크리스트(프로필) 데이터를 Firestore에서 조회하여
/// 화면에 표시하는 UI를 제공합니다.
/// - 각 체크리스트 페이지별 질문과 해당 응답을 목록으로 출력합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmate1/ui/tabs/matching/checklist/checklist_item.dart'; // checklistPages 참조

class ProfileScreen extends StatefulWidget {
  final String targetUid;
  ProfileScreen({required this.targetUid});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? checklist;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    var doc = await _firestore
        .collection('users')
        .doc(widget.targetUid)
        .collection('checklist')
        .doc('latest')
        .get();
    if (doc.exists) setState(() { checklist = doc.data(); });
  }

  String _formatAnswer(dynamic answer) {
    if (answer == null) return "미작성";
    if (answer is List) return answer.join(', ');
    return answer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (checklist == null) {
      return Scaffold(appBar: AppBar(title: Text('체크리스트')), body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('체크리스트 보기')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: checklistPages.length,
        itemBuilder: (context, pageIndex) {
          final page = checklistPages[pageIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('페이지 ${pageIndex + 1}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...page.map((question) {
                final answer = checklist![question.id];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.question, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text(_formatAnswer(answer), style: TextStyle(fontSize: 14)),
                      Divider(),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
