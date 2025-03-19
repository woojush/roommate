import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/service/account/account_service.dart';
import 'package:findmate1/ui/account/login_screen.dart';
import 'package:findmate1/ui/tabs/profile/profile_screen.dart';
import 'package:findmate1/ui/tabs/matching/checklist/checklist_edit_screen.dart';
import 'package:findmate1/theme.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmate1/widgets/warning_dialog.dart';

class ProfileDetailScreen extends StatefulWidget {
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  String userName = "";
  String profileImage = "";
  String dorm = "";
  String roomType = "";
  String dormDuration = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 사용자 기본 정보는 users 컬렉션에서 가져옴
      final userData = await AccountService.getUserProfile(user.uid);
      // 기숙사 정보는 checklists 컬렉션에서 가져옴
      final checklistDoc = await FirebaseFirestore.instance
          .collection('checklists')
          .doc(user.uid)
          .get();

      setState(() {
        userName = userData?['name'] ?? "사용자";
        profileImage = userData?['profileImage'] ?? "";
        dorm = checklistDoc.exists ? (checklistDoc.data()?['dorm'] ?? "정보 없음") : "정보 없음";
        roomType = checklistDoc.exists ? (checklistDoc.data()?['roomType'] ?? "정보 없음") : "정보 없음";
        dormDuration = checklistDoc.exists ? (checklistDoc.data()?['dormDuration'] ?? "정보 없음") : "정보 없음";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(title: '내 정보'),
      body: Container(
        color: Colors.white,
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 프로필 이미지와 사용자 이름 (가로 배치)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : AssetImage("assets/default_profile.png") as ImageProvider,
                ),
                const SizedBox(width: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold, // 폰트 굵게 적용
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 체크리스트 수정 버튼
            Container(
              width: double.infinity,
              height: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black, // 다크그레이 배경
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // 버튼 모서리 둥글게
                  ),
                ),
                onPressed: () {
                  // 체크리스트가 작성되지 않은 경우 경고 다이얼로그 띄우기
                  if (dorm == "정보 없음" ||
                      roomType == "정보 없음" ||
                      dormDuration == "정보 없음") {
                    showDialog(
                      context: context,
                      builder: (context) => WarningDialog(
                        message: "체크리스트를 작성하지 않았습니다.",
                        buttonCount: 1,
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChecklistEditScreen(),
                      ),
                    );
                  }
                },
                child: const Text(
                  '나의 체크리스트',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상: 화이트
                    fontSize: 16, // 글자 크기
                    fontWeight: FontWeight.bold, // 글자 두껍게
                  ),
                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
                ),
              ),
            ),
            const SizedBox(height: 25),
            // 기숙사 정보 카드
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.blue),
                      title: const Text(
                        "생활관",
                        style: TextStyle(fontWeight: FontWeight.bold), // 굵은 폰트
                      ),
                      subtitle: Text(
                        dorm,
                        // style: const TextStyle(fontWeight: FontWeight.bold), // 굵은 폰트
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.king_bed, color: Colors.green),
                      title: const Text(
                        "인실",
                        style: TextStyle(fontWeight: FontWeight.bold), // 굵은 폰트
                      ),
                      subtitle: Text(
                        roomType,
                        // style: const TextStyle(fontWeight: FontWeight.bold), // 굵은 폰트
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.schedule, color: Colors.orange),
                      title: const Text(
                        "기숙사 기간",
                        style: TextStyle(fontWeight: FontWeight.bold), // 굵은 폰트
                      ),
                      subtitle: Text(
                        dormDuration,
                        // style: const TextStyle(fontWeight: FontWeight.bold), // 굵은 폰트
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
