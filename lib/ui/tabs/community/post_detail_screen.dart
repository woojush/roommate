/// ---------------------------------------------------------------------------
/// 이 파일은 선택한 게시글의 상세 정보를 표시하는 UI를 제공합니다.
/// - 게시글의 제목, 내용, 이미지 등을 상세하게 보여줍니다.
/// - 이미지 클릭 시 풀스크린 이미지 뷰어(FullScreenImageViewer)로 전환됩니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'full_screen_image_viewer.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrls.isNotEmpty)
              Container(
                height: 250,
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
              padding: const EdgeInsets.all(12.0),
              child: Text(
                post.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
