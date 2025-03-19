/// post.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 커뮤니티 게시글(Post)의 데이터 모델을 정의합니다.
/// ---------------------------------------------------------------------------
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final List<String> imageUrls;
  final String boardType;
  final Timestamp timestamp;
  final int likeCount;
  final int commentCount;
  final int scrapCount;
  final List<String> likedUsers;
  final String userId; // 게시글 작성자의 uid 추가

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.boardType,
    required this.timestamp,
    this.likeCount = 0,
    this.commentCount = 0,
    this.scrapCount = 0,
    this.likedUsers = const [],
    required this.userId,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // 안전한 int 변환 함수
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return 0;
    }

    // 안전한 List<String> 변환 함수
    List<String> safeStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['images'] ?? []),
      boardType: data['boardType'] ?? 'free',
      timestamp: data['created_at'] ?? Timestamp.now(),
      likeCount: safeInt(data['likeCount']),
      commentCount: safeInt(data['commentCount']),
      scrapCount: safeInt(data['scrapCount']),
      likedUsers: safeStringList(data['likedUsers']),
      userId: data['userId'] ?? '', // Firestore에 저장된 게시글 작성자의 uid를 읽어옴
    );
  }
}
