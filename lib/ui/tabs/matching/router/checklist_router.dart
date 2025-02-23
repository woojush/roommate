/// ---------------------------------------------------------------------------
/// 이 파일은 사용자가 체크리스트를 작성했는지 여부를 확인하고,
/// 체크리스트 미작성 시 체크리스트 작성 화면(ChecklistScreen)으로, 작성되었으면
/// 매칭(방 목록) 화면(RoomListScreen)으로 라우팅하는 역할을 합니다.
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

  Future<void> _checkChecklistStatus() async {
    setState(() { _isLoading = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('checklist')
          .doc('latest');
      final docSnapshot = await docRef.get();
      _isChecklistComplete = docSnapshot.exists;
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChecklistScreen()),
                  );
                  if (result == true) _checkChecklistStatus();
                },
                child: Text('체크리스트 작성', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      );
    }
    return RoomListScreen();
  }
}
