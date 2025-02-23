/// ---------------------------------------------------------------------------
/// 이 파일은 커뮤니티 게시글(Post)의 데이터 모델을 정의합니다.
/// - Post 클래스는 게시글의 고유 ID, 제목, 내용, 이미지 URL 목록, 게시판 종류, 생성 시각 등의 정보를 보관합니다.
/// - fromDocument() 팩토리 생성자를 통해 Firestore의 DocumentSnapshot을 Post 객체로 변환합니다.
/// ---------------------------------------------------------------------------


import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final List<String> imageUrls;
  final String boardType;
  final Timestamp timestamp;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.boardType,
    required this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['images'] ?? []),
      boardType: data['boardType'] ?? 'free',
      timestamp: data['created_at'] ?? Timestamp.now(),
    );
  }
}
