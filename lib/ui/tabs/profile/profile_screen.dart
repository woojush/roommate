import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmate1/ui/screens/settings/settings_main.dart';
import 'package:findmate1/widgets/main_tab_appbar.dart';
import 'package:findmate1/widgets/common_card.dart';
import 'package:findmate1/ui/tabs/profile/profile_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? targetUid; // room_list_screen에서 전달한 사용자 uid를 받을 수 있도록 함

  const ProfileScreen({Key? key, this.targetUid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "";
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Firestore의 "users" 컬렉션에서 사용자 데이터를 가져옵니다.
  Future<void> _loadUserData() async {
    final uid = widget.targetUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          userName = data["userName"] ?? "사용자";
          profileImage = data["profileImage"] ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTabAppBar(
        title: '프로필',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CommonCard를 직접 사용하여 프로필 UI 구성
            CommonCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileDetailScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : const AssetImage("assets/default_profile.png")
                    as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  // 사용자 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "내 프로필 보기",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // 화살표 아이콘 (더 보기)
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
            // 추가 콘텐츠가 있다면 여기에 배치합니다.
          ],
        ),
      ),
    );
  }
}
