import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_detail_screen.dart';
import 'full_screen_image_viewer.dart';
import 'package:findmate1/service/tabs/community/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  /// 시간대 계산 함수
  /// - 1분 이하: "방금"
  /// - 1시간 이하: "x분 전"
  /// - 24시간 이하: "x시간 전"
  /// - 그 이상: "x일 전"
  String _timeAgo(Timestamp timestamp) {
    final date = timestamp.toDate();
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return "방금";
    } else if (diff.inHours < 1) {
      return "${diff.inMinutes}분 전";
    } else if (diff.inDays < 1) {
      return "${diff.inHours}시간 전";
    } else {
      return "${diff.inDays}일 전";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 게시글 상세화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        // 하단 구분선
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 이미지 (있을 경우)
            if (post.imageUrls.isNotEmpty)
              Container(
                height: 200,
                color: Colors.grey[200],
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                  ),
                  items: post.imageUrls.map((url) {
                    return Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            // 전체화면 이미지 뷰어
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageViewer(
                                  imageUrls: post.imageUrls,
                                  initialIndex: post.imageUrls.indexOf(url),
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
                      },
                    );
                  }).toList(),
                ),
              ),

            if (post.imageUrls.isNotEmpty) const SizedBox(height: 8),

            /// 제목
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),


            /// 본문 요약
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),
            /// 상단: [시간대 | 익명]
            Row(
              children: [
                Text(
                  _timeAgo(post.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "| 익명",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            /// 좋아요 수와 댓글 수 (1 이상일 때만 표시)
            Row(
              children: [
                // 좋아요 수
                if ((post.likeCount) > 0) ...[
                  Icon(Icons.favorite_border, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    "${post.likeCount}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                ],
                // 댓글 수
                if ((post.commentCount) > 0) ...[
                  Icon(Icons.comment, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${post.commentCount}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
