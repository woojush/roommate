/// checklist_router.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 사용자가 체크리스트를 작성했는지 여부를 확인하고,
/// 체크리스트 미작성 시 체크리스트 작성 화면(ChecklistScreen)으로,
/// 작성되었으면 매칭(방 목록) 화면(RoomListScreen)으로 라우팅하는 역할을 합니다.
///
/// 기존에는 'users/{uid}/checklist/latest' 경로에 문서를 두었으나,
/// 이제 'checklists/{uid}' 최상위 컬렉션 사용 방식으로 변경합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/ui/tabs/matching/checklist/checklist_screen.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_list_screen.dart';

class ChecklistRouter extends StatefulWidget {
  const ChecklistRouter({Key? key}) : super(key: key);

  @override
  _ChecklistRouterState createState() => _ChecklistRouterState();
}

class _ChecklistRouterState extends State<ChecklistRouter> {
  bool _isChecklistComplete = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkChecklistStatus();
  }

  /// Firestore에서 'checklists/{uid}' 문서를 조회하여,
  /// 체크리스트가 작성되었는지(doc.exists) 확인
  Future<void> _checkChecklistStatus() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("현재 로그인한 사용자 UID: ${user.uid}");
      // 최상위 컬렉션 checklists / 문서 ID=user.uid
      final docRef = FirebaseFirestore.instance
          .collection('checklists')
          .doc(user.uid);

      final docSnapshot = await docRef.get();
      _isChecklistComplete = docSnapshot.exists;

      print("Firestore 경로 (${docRef.path})의 문서 존재 여부: ${docSnapshot.exists}");
    } else {
      print("사용자가 로그인되어 있지 않습니다.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 체크리스트 미작성 → 체크리스트 작성 화면
    if (!_isChecklistComplete) {
      return Scaffold(
        appBar: AppBar(title: Text('룸메이트 매칭')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('체크리스트가 작성되지 않았습니다.'),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  // ChecklistScreen에서 완료 후 true 반환
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChecklistScreen()),
                  );
                  if (result == true) _checkChecklistStatus();
                },
                child: Text(
                  '체크리스트 작성',
                  style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 체크리스트 작성 완료 → 방 목록 화면
    return RoomListScreen();
  }
}
