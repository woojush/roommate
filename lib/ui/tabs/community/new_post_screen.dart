/// ---------------------------------------------------------------------------
/// 이 파일은 사용자가 새로운 게시글을 작성할 수 있는 UI를 제공합니다.
/// - 제목, 내용 입력 필드와 이미지 선택 기능, 그리고 선택된 이미지의 미리보기를 포함합니다.
/// - 작성 완료 시, PostService를 호출하여 이미지 업로드 및 게시글 데이터를 Firestore에 저장합니다.
///
/// 게시글을 최상위 컬렉션('posts')에 저장하되, boardType을 하나의 필드로 유지해
/// 나중에 where("boardType", isEqualTo: ...)로 필터할 수 있게 설계했습니다.
/// ---------------------------------------------------------------------------

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:findmate1/service/tabs/community/post_service.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';

class NewPostScreen extends StatefulWidget {
  final String boardType;

  const NewPostScreen({Key? key, required this.boardType}) : super(key: key);

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final PostService _postService = PostService();

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      // 이미지 업로드
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _postService.uploadImages(_selectedImages);
        if (imageUrls.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("이미지 업로드에 실패했습니다.")),
          );
          setState(() => _isUploading = false);
          return;
        }
      }

      // Firestore 저장
      try {
        await _postService.submitPost(
          title: _titleController.text,
          content: _contentController.text,
          imageUrls: imageUrls,
          boardType: widget.boardType,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("게시글이 성공적으로 작성되었습니다.")),
        );

        // 입력값 초기화
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedImages.clear();
          _isUploading = false;
        });
        Navigator.pop(context);
      } catch (e) {
        print("Error submitting post: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("게시글 작성 중 오류가 발생했습니다.")),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(title: "게시글 작성"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isUploading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "제목",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "제목을 입력하세요." : null,
                ),
                SizedBox(height: 16),
                // 내용
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "내용",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  validator: (value) =>
                  value == null || value.isEmpty ? "내용을 입력하세요." : null,
                ),
                SizedBox(height: 16),

                // 선택된 이미지 미리보기
                Text("선택된 이미지:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _selectedImages.isEmpty
                    ? Text("이미지가 선택되지 않았습니다.")
                    : Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(4),
                        width: 100,
                        child: Image.file(
                          File(_selectedImages[index].path),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),

                // 버튼 행
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: Icon(Icons.image),
                      label: Text("이미지 선택"),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _submitPost,
                      child: Text("게시글 올리기"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
