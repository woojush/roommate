/// ---------------------------------------------------------------------------
/// 이 파일은 커뮤니티 게시글과 관련된 백엔드 로직을 담당하는 서비스 파일입니다.
/// - 이미지 업로드: 사용자가 선택한 이미지를 Firebase Storage에 업로드하고, 다운로드 URL 목록을 반환합니다.
/// - 게시글 제출: 사용자가 작성한 게시글 데이터를 Firestore의 'posts' 컬렉션에 저장합니다.
/// ---------------------------------------------------------------------------

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class PostService {
  Future<List<String>> uploadImages(List<XFile> selectedImages) async {
    List<String> downloadUrls = [];
    for (XFile image in selectedImages) {
      try {
        File file = File(image.path);
        String fileName =
            DateTime.now().millisecondsSinceEpoch.toString() + "_" + image.name;
        Reference ref =
        FirebaseStorage.instance.ref().child('post_images').child(fileName);
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return downloadUrls;
  }

  Future<void> submitPost({
    required String title,
    required String content,
    required List<String> imageUrls,
    required String boardType,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    Map<String, dynamic> postData = {
      'title': title,
      'content': content,
      'images': imageUrls,
      'boardType': boardType,
      'created_at': FieldValue.serverTimestamp(),
      'user_id': currentUser.uid,
    };

    await FirebaseFirestore.instance.collection('posts').add(postData);
  }
}
