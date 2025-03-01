/// ---------------------------------------------------------------------------
/// 이 파일은 커뮤니티 게시글과 관련된 백엔드 로직을 담당하는 서비스 파일입니다.
/// - 이미지 업로드: 사용자가 선택한 이미지를 Firebase Storage에 업로드하고, 다운로드 URL 목록을 반환합니다.
/// - 게시글 제출: 사용자가 작성한 게시글 데이터를 Firestore의 'posts' 컬렉션에 저장합니다.
///   (boardType 필드를 포함해, 특정 게시판 분류를 필터링하기 쉽도록 구성)
/// ---------------------------------------------------------------------------

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class PostService {
  /// [uploadImages]
  /// 사용자가 선택한 이미지를 Firebase Storage('post_images') 경로에 업로드 후, 다운로드 URL 리스트를 반환.
  Future<List<String>> uploadImages(List<XFile> selectedImages) async {
    List<String> downloadUrls = [];

    for (XFile image in selectedImages) {
      try {
        // 이미지 파일 준비
        final file = File(image.path);
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

        // Storage 참조 생성
        final ref = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child(fileName);

        // 업로드 진행
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;

        // 다운로드 URL 획득
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
        // 한 장이라도 업로드 실패하면, 필요한 로직에 따라 처리 가능
        // 여기서는 실패한 이미지만 누락하고 계속 진행
      }
    }
    return downloadUrls;
  }

  /// [submitPost]
  /// Firestore의 'posts' 컬렉션에 새 문서를 생성하여 게시글 데이터를 저장.
  /// [boardType]을 필드에 포함함으로써, 나중에 where('boardType', == ...)로 필터 가능.
  Future<void> submitPost({
    required String title,
    required String content,
    required List<String> imageUrls,
    required String boardType,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    // Firestore 문서에 저장할 데이터
    final postData = <String, dynamic>{
      'title': title,
      'content': content,
      'images': imageUrls,
      'boardType': boardType,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': currentUser.uid,
    };

    // auto ID로 새 게시글 문서 생성
    await FirebaseFirestore.instance
        .collection('posts')
        .add(postData);
  }
}
