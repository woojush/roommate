import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/service/account/account_service.dart';
import 'checklist_edit_screen.dart';
import 'package:findmate1/theme.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';

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
      final userData = await AccountService.getUserProfile(user.uid);
      if (userData != null) {
        setState(() {
          userName = userData['name'] ?? "사용자";
          profileImage = userData['profileImage'] ?? "";
          dorm = userData['dorm'] ?? "정보 없음";
          roomType = userData['roomType'] ?? "정보 없음";
          dormDuration = userData['dormDuration'] ?? "정보 없음";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(title: '내 정보'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 🟢 프로필 이미지 + 사용자 이름 (가로 배치)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : AssetImage("assets/default_profile.png") as ImageProvider,
                ),
                SizedBox(width: 16), // 아이콘과 텍스트 간격 조절
                Text(
                  userName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
              width: double.infinity, // 가로 전체 크기
              height: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black, // 다크그레이 배경
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // 버튼 모서리 둥글게
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChecklistEditScreen(),
                    ),
                  );
                },
                child: Text(
                  '체크리스트 수정',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상: 화이트
                    fontSize: 16, // 글자 크기
                    fontWeight: FontWeight.bold, // 글자 두껍게
                  ),
                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
                ),
              ),
            ),
            SizedBox(height: 25),

            // 🟢 프로필 정보 카드 (생활관, 인실, 기숙사 기간)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.blue),
                      title: Text("생활관"),
                      subtitle: Text(dorm),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.king_bed, color: Colors.green),
                      title: Text("인실"),
                      subtitle: Text(roomType),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.schedule, color: Colors.orange),
                      title: Text("기숙사 기간"),
                      subtitle: Text(dormDuration),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ));
  }
}
