import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:findmate1/service/tabs/community/post.dart';
import 'package:findmate1/service/tabs/community/post_service.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';
import 'full_screen_image_viewer.dart';
import 'comment_item.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostService _postService = PostService();

  late int _likeCount;
  late int _commentCount;
  late int _scrapCount;
  late bool _isLikedByMe;
  late bool _isScrappedByMe;

  List<QueryDocumentSnapshot> _comments = [];
  bool _isLoadingComments = true;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _commentCount = widget.post.commentCount;
    _scrapCount = widget.post.scrapCount;

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    _isLikedByMe =
        currentUid != null && widget.post.likedUsers.contains(currentUid);
    _isScrappedByMe = false;

    _loadComments();
  }

  // 게시판 이름 결정 (Post.boardType에 따라)
  String get boardName {
    if (widget.post.boardType == 'free') return "자유게시판";
    if (widget.post.boardType == 'suggest') return "건의사항 게시판";
    return "커뮤니티";
  }

  // 작성 시간 포맷 (예: 03/14 11:35)
  String get formattedTime {
    final date = widget.post.timestamp.toDate();
    return DateFormat('MM/dd HH:mm').format(date);
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    final docRef =
    FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    final commentsRef =
    docRef.collection('comments').orderBy('created_at', descending: false);
    final snapshot = await commentsRef.get();
    setState(() {
      _comments = snapshot.docs;
      _isLoadingComments = false;
    });
  }

  Future<void> _onLikePressed() async {
    await _postService.toggleLike(widget.post);
    setState(() {
      if (_isLikedByMe) {
        _likeCount = (_likeCount > 0) ? _likeCount - 1 : 0;
        _isLikedByMe = false;
      } else {
        _likeCount += 1;
        _isLikedByMe = true;
      }
    });
  }

  Future<void> _onScrapPressed() async {
    await _postService.toggleScrap(widget.post);
    setState(() {
      if (_isScrappedByMe) {
        _scrapCount = (_scrapCount > 0) ? _scrapCount - 1 : 0;
        _isScrappedByMe = false;
      } else {
        _scrapCount += 1;
        _isScrappedByMe = true;
      }
    });
  }

  void _onCommentButtonPressed() {
    FocusScope.of(context).requestFocus(_commentFocusNode);
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      // parentCommentId이 null이면 최상위 댓글로 처리
      await _postService.addComment(widget.post, text);
      setState(() {
        _commentCount += 1;
      });
      _commentController.clear();
      _loadComments();
      FocusScope.of(context).unfocus();
    }
  }

  String _formatTimestamp(DateTime dt) {
    return "${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(
        title: boardName,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // 기타 액션 처리
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 영역: 게시글 본문 및 이미지
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 작성자 및 작성 시간
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/default_profile.png'),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 실제 작성자와 비교해 "익명(글쓴이)" 처리 가능 (여기선 단순 "익명")
                          const Text(
                            "익명",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 이미지 영역 (있을 경우)
                  if (widget.post.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          viewportFraction: 1.0,
                          enableInfiniteScroll: false,
                        ),
                        items: widget.post.imageUrls.map((url) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImageViewer(
                                    imageUrls: widget.post.imageUrls,
                                    initialIndex:
                                    widget.post.imageUrls.indexOf(url),
                                  ),
                                ),
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (widget.post.imageUrls.isNotEmpty)
                    const SizedBox(height: 8),
                  // 제목 및 내용
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.post.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  // 공감, 댓글, 스크랩 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: _onLikePressed,
                          icon: Icon(
                            _isLikedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 20,
                          ),
                          label: Text(
                            "공감${_likeCount > 0 ? ' $_likeCount' : ''}",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _onCommentButtonPressed,
                          icon: const Icon(Icons.comment, color: Colors.grey, size: 20),
                          label: Text(
                            "댓글${_commentCount > 0 ? ' $_commentCount' : ''}",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _onScrapPressed,
                          icon: Icon(
                            _isScrappedByMe
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: Colors.blue,
                            size: 20,
                          ),
                          label: Text(
                            "스크랩${_scrapCount > 0 ? ' $_scrapCount' : ''}",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // 댓글 리스트 (댓글이 없으면 아무것도 표시하지 않음)
                  _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: _comments.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final commentDoc = _comments[index];
                      final commentData =
                      commentDoc.data() as Map<String, dynamic>;
                      final nickname =
                          commentData['nickname'] ?? "익명";
                      final text = commentData['text'] ?? "";
                      final createdAt =
                      commentData['created_at'] as Timestamp?;
                      final timeString = createdAt != null
                          ? _formatTimestamp(createdAt.toDate())
                          : "";
                      final commentLikeCount =
                          commentData['commentLikeCount'] ?? 0;
                      final targetUid = commentData['userId'] ?? "";

                      return CommentItem(
                        nickname: nickname,
                        commentText: text,
                        timeString: timeString,
                        likeCount: commentLikeCount,
                        // 필요한 액션 콜백들 (각 기능은 실제 로직에 맞게 구현)
                        onReply: () {
                          print("대댓글 달기 클릭: $nickname");
                        },
                        onLike: () {
                          print("댓글 좋아요 클릭: $nickname");
                        },
                        onToggleAlarm: () {
                          print("대댓글 알림 켜기 클릭: $nickname");
                        },
                        onSendMessage: () {
                          print("쪽지 보내기 클릭: $nickname");
                        },
                        onReport: () {
                          print("신고 클릭: $nickname");
                        },
                        onBlock: () {
                          print("차단 클릭: $nickname");
                        },
                        // 게시물 관련 정보 전달
                        postTitle: widget.post.title,
                        boardName: boardName,
                        postId: widget.post.id,
                        targetUid: targetUid,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // 댓글 입력창
          SafeArea(
            child: Container(
              color: Colors.grey.shade200,
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundImage:
                    AssetImage('assets/default_profile.png'),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      decoration: const InputDecoration(
                        hintText: "댓글을 입력하세요.",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  InkWell(
                    onTap: _submitComment,
                    child: const Icon(Icons.send, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
