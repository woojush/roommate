/// ---------------------------------------------------------------------------
/// 이 파일은 개별 게시글을 카드 형태로 요약해서 보여주는 UI 위젯을 정의합니다.
/// - 게시글의 제목, 내용 일부, 이미지(있을 경우)를 표시합니다.
/// - 터치 시 게시글 상세 화면(PostDetailScreen)으로 내비게이션합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_detail_screen.dart';
import 'full_screen_image_viewer.dart';
import 'package:findmate1/service/tabs/community/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrls.isNotEmpty)
              Container(
                height: 200,
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
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                post.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
