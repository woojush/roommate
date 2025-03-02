import 'package:flutter/material.dart';
import 'package:findmate1/ui/tabs/profile/profile_detail_screen.dart';

class ProfileCard extends StatelessWidget {
  final String userName;
  final String profileImage;

  const ProfileCard({
    super.key,
    required this.userName,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 40,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage) as ImageProvider
                    : const AssetImage("assets/default_profile.png"),
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
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
