/// ---------------------------------------------------------------------------
/// 이 파일은 선택된 게시판(자유게시판 또는 건의사항 게시판)의 게시글 목록을 표시하는 UI를 제공합니다.
/// - Firestore 스트림을 이용해 게시글 데이터를 실시간으로 가져오며, ListView로 출력합니다.
/// - FloatingActionButton을 눌러 게시글 작성(NewPostScreen) 화면으로 이동합니다.
/// ---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_card.dart';
import 'new_post_screen.dart';
import 'package:findmate1/service/tabs/community/post.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';

class BoardScreen extends StatelessWidget {
  final String boardType;
  const BoardScreen({Key? key, required this.boardType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(
        title: boardType == 'free' ? "자유게시판" : "건의사항 게시판",
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('boardType', isEqualTo: boardType)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("오류가 발생했습니다."));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs;
          if (docs == null || docs.isEmpty) return Center(child: Text("게시글이 없습니다."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final post = Post.fromDocument(docs[index]);
              return PostCard(post: post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewPostScreen(boardType: boardType),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
