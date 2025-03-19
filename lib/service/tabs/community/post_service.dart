/// post_service.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 커뮤니티 게시글과 관련된 백엔드 로직을 담당하는 서비스 파일입니다.
/// 이미지 업로드, 게시글 제출, 좋아요 토글, 스크랩 토글, 댓글(및 대댓글) 추가/삭제, 개인 쪽지 전송 기능을 포함합니다.
/// ---------------------------------------------------------------------------

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:findmate1/service/tabs/community/post.dart';

class PostService {
  /// 사용자가 선택한 이미지를 Firebase Storage('post_images') 경로에 업로드한 후,
  /// 다운로드 URL 리스트를 반환합니다.
  Future<List<String>> uploadImages(List<XFile> selectedImages) async {
    List<String> downloadUrls = [];
    for (XFile image in selectedImages) {
      try {
        final file = File(image.path);
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final ref = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child(fileName);
        final snapshot = await ref.putFile(file);
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return downloadUrls;
  }

  /// Firestore의 'posts' 컬렉션에 새 문서를 생성하여 게시글 데이터를 저장합니다.
  /// boardType 필드를 포함해 나중에 특정 게시판별로 필터링이 가능하도록 합니다.
  Future<void> submitPost({
    required String title,
    required String content,
    required List<String> imageUrls,
    required String boardType,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final postData = <String, dynamic>{
      'title': title,
      'content': content,
      'images': imageUrls,
      'boardType': boardType,
      'created_at': FieldValue.serverTimestamp(),
      'userId': currentUser.uid, // 게시글 작성자의 UID
      'likeCount': 0,
      'commentCount': 0,
      'scrapCount': 0,
      'likedUsers': [],
      // 게시글 내 익명 닉네임 매핑 (댓글 작성 시 번호 부여에 사용)
      'nicknameMapping': {},
    };

    await FirebaseFirestore.instance.collection('posts').add(postData);
  }

  /// 게시글에 대한 좋아요 토글 기능
  Future<void> toggleLike(Post post) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final docRef = FirebaseFirestore.instance.collection('posts').doc(post.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      final currentLikeCount = (data['likeCount'] ?? 0) as int;
      final likedUsers = List<String>.from(data['likedUsers'] ?? []);
      if (likedUsers.contains(currentUser.uid)) {
        // 좋아요 취소
        likedUsers.remove(currentUser.uid);
        transaction.update(docRef, {
          'likedUsers': likedUsers,
          'likeCount': currentLikeCount > 0 ? currentLikeCount - 1 : 0,
        });
      } else {
        // 좋아요 추가
        likedUsers.add(currentUser.uid);
        transaction.update(docRef, {
          'likedUsers': likedUsers,
          'likeCount': currentLikeCount + 1,
        });
      }
    });
  }

  /// 게시글에 대한 스크랩 토글 기능
  Future<void> toggleScrap(Post post) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final docRef = FirebaseFirestore.instance.collection('posts').doc(post.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      final currentScrapCount = (data['scrapCount'] ?? 0) as int;
      final scrapUsers = List<String>.from(data['scrapUsers'] ?? []);
      if (scrapUsers.contains(currentUser.uid)) {
        scrapUsers.remove(currentUser.uid);
        transaction.update(docRef, {
          'scrapUsers': scrapUsers,
          'scrapCount': currentScrapCount > 0 ? currentScrapCount - 1 : 0,
        });
      } else {
        scrapUsers.add(currentUser.uid);
        transaction.update(docRef, {
          'scrapUsers': scrapUsers,
          'scrapCount': currentScrapCount + 1,
        });
      }
    });
  }

  /// 게시글에 댓글(또는 대댓글)을 추가합니다.
  /// [parentCommentId]가 null이면 최상위 댓글, 값이 있으면 해당 댓글에 대한 대댓글(1단계)로 처리합니다.
  /// 익명 닉네임 부여는 기존 댓글들 중 할당된 번호를 기준으로 진행합니다.
  Future<void> addComment(Post post, String commentText, {String? parentCommentId}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);
    final commentsRef = postRef.collection('comments');

    String nickname;

    // 부모 댓글이 있는 경우 대댓글 처리
    if (parentCommentId != null) {
      // 대댓글인 경우, 해당 부모 댓글에 대해 이미 댓글을 남긴 적이 있다면 기존 닉네임 사용
      QuerySnapshot existingReplies = await commentsRef
          .where('userId', isEqualTo: currentUser.uid)
          .where('parentCommentId', isEqualTo: parentCommentId)
          .get();
      if (existingReplies.docs.isNotEmpty) {
        final data = existingReplies.docs.first.data() as Map<String, dynamic>;
        nickname = data['nickname'] ?? "";
        if (nickname.isEmpty) nickname = "익명";
      } else {
        // 대댓글 최초 작성인 경우, 게시글 전체 댓글(부모 포함)에서 익명 번호 계산
        QuerySnapshot allCommentsSnapshot = await commentsRef.get();
        int maxIndex = 0;
        for (var doc in allCommentsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final existingNickname = data['nickname'] ?? "";
          // 게시글 작성자의 닉네임은 "익명(글쓴이)"이므로 제외
          if (existingNickname == "익명(글쓴이)") continue;
          if (existingNickname.startsWith("익명")) {
            final numPart = existingNickname.substring(2);
            int? num = int.tryParse(numPart);
            if (num != null && num > maxIndex) {
              maxIndex = num;
            }
          }
        }
        nickname = "익명${maxIndex + 1}";
      }
    } else {
      // 최상위 댓글 처리
      QuerySnapshot existingComments = await commentsRef
          .where('userId', isEqualTo: currentUser.uid)
          .where('parentCommentId', isEqualTo: null)
          .get();
      if (existingComments.docs.isNotEmpty) {
        final data = existingComments.docs.first.data() as Map<String, dynamic>;
        nickname = data['nickname'] ?? "";
        if (nickname.isEmpty) nickname = "익명";
      } else {
        DocumentSnapshot postSnapshot = await postRef.get();
        if (postSnapshot.exists) {
          final postData = postSnapshot.data() as Map<String, dynamic>;
          if (currentUser.uid == postData['userId']) {
            nickname = "익명(글쓴이)";
          } else {
            QuerySnapshot allCommentsSnapshot = await commentsRef.get();
            int maxIndex = 0;
            for (var doc in allCommentsSnapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final existingNickname = data['nickname'] ?? "";
              if (existingNickname == "익명(글쓴이)") continue;
              if (existingNickname.startsWith("익명")) {
                final numPart = existingNickname.substring(2);
                int? num = int.tryParse(numPart);
                if (num != null && num > maxIndex) {
                  maxIndex = num;
                }
              }
            }
            nickname = "익명${maxIndex + 1}";
          }
        } else {
          nickname = "익명";
        }
      }
    }

    // 댓글 Document 생성 데이터 (대댓글인 경우 parentCommentId 필드 포함)
    Map<String, dynamic> commentData = {
      'text': commentText,
      'created_at': FieldValue.serverTimestamp(),
      'userId': currentUser.uid,
      'nickname': nickname,
      // 대댓글 여부 판별을 위한 필드 (최상위 댓글은 null)
      'parentCommentId': parentCommentId,
    };

    await commentsRef.add(commentData);

    // 게시글의 commentCount 업데이트 (배치 쓰기)
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) return;
      final data = postSnapshot.data() as Map<String, dynamic>? ?? {};
      final currentCount = (data['commentCount'] ?? 0) as int;
      transaction.update(postRef, {'commentCount': currentCount + 1});
    });
  }

  /// 댓글 또는 대댓글을 삭제하는 기능
  /// [commentId]는 삭제할 댓글 Document의 ID.
  Future<void> deleteComment(Post post, String commentId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);
    final commentRef = postRef.collection('comments').doc(commentId);
    // 삭제 전 필요한 경우, 대댓글도 함께 삭제하는 로직 추가 가능 (1단계 대댓글만 지원)
    await commentRef.delete();

    // 게시글의 commentCount 감소
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) return;
      final data = postSnapshot.data() as Map<String, dynamic>? ?? {};
      final currentCount = (data['commentCount'] ?? 0) as int;
      transaction.update(postRef, {'commentCount': currentCount > 0 ? currentCount - 1 : 0});
    });
  }

  /// 개인 쪽지 전송 기능
  /// 새로운 컬렉션 'privateMessages'에 대화 Document를 생성하거나 기존 대화에 메시지를 추가합니다.
  /// 각 대화 Document에는 'participantIds', 'participantNicks', 'postId' 등의 메타데이터와
  /// 서브컬렉션 'messages'에 실제 메시지들이 저장됩니다.
  Future<void> sendPrivateMessage({
    required String chatRoomId, // 대화 Document ID; 없으면 새로 생성
    required String text,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final privateMessagesRef = FirebaseFirestore.instance.collection('privateMessages');
    final messageData = {
      'text': text,
      'senderId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // chatRoomId가 제공되면 해당 Document의 'messages' 서브컬렉션에 추가,
    // 그렇지 않으면 새로운 대화 Document를 생성합니다.
    if (chatRoomId.isNotEmpty) {
      final chatRoomRef = privateMessagesRef.doc(chatRoomId);
      await chatRoomRef.collection('messages').add(messageData);
    } else {
      // 새로운 대화 Document 생성 예시:
      final newChatRoomRef = await privateMessagesRef.add({
        'participantIds': [currentUser.uid],
        // 필요에 따라 대화 시작 시 게시물 정보, 상대방 익명 닉네임 등 추가
        'created_at': FieldValue.serverTimestamp(),
      });
      await newChatRoomRef.collection('messages').add(messageData);
    }
  }
}
