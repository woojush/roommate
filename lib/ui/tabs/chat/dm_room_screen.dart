import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';

class DmRoomScreen extends StatefulWidget {
  final String chatRoomId;      // 개인 쪽지방 문서 ID
  final String postTitle;       // 게시물 제목
  final String boardName;       // 게시판 이름 (예: "자유게시판")
  final String targetNickname;  // 상대방 익명 닉네임

  const DmRoomScreen({
    Key? key,
    required this.chatRoomId,
    required this.postTitle,
    required this.boardName,
    required this.targetNickname,
  }) : super(key: key);

  @override
  _DmRoomScreenState createState() => _DmRoomScreenState();
}

class _DmRoomScreenState extends State<DmRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 날짜 표시용 예시
  final String dateString = DateFormat('yyyy.MM.dd').format(DateTime.now());

  // Firestore 참조 (privateMessages/{chatRoomId}/messages)
  late CollectionReference messagesRef;

  @override
  void initState() {
    super.initState();
    messagesRef = FirebaseFirestore.instance
        .collection('privateMessages')
        .doc(widget.chatRoomId)
        .collection('messages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(
        title: "${widget.postTitle}의 댓글",
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // 추가 메뉴 로직(옵션)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단(Expanded) 영역에 "카드 + 메시지 목록"을 스크롤로 표시
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("오류 발생: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // ListView 에서 첫 번째 아이템(인덱스 0)은 "카드",
                // 이후 아이템(인덱스 1~N)은 "메시지"를 표시하도록 구성
                final itemCount = docs.length + 1;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    // 0번 인덱스 = 카드
                    if (index == 0) {
                      return _buildTopCard();
                    }
                    // 그 외 = 메시지
                    else {
                      final msgIndex = index - 1;
                      final data = docs[msgIndex].data() as Map<String, dynamic>;
                      final senderId = data['senderId'] ?? "";
                      final text = data['text'] ?? "";
                      final timestamp = data['timestamp'] as Timestamp?;
                      final timeStr = (timestamp != null)
                          ? _formatTimestamp(timestamp.toDate())
                          : "";

                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      final isMe = (senderId == currentUid);

                      return Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 12),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),

          // 메시지 입력창 (하단 고정)
          SafeArea(
            child: Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "메시지를 입력하세요...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카드(상단)에 표시할 UI
  /// 날짜 + 게시판 이름 + 게시물 제목 + "게시물 바로가기" 버튼
  Widget _buildTopCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        // 날짜
        Center(
          child: Container(
            width: 90,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              dateString,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 카드
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.boardName, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  "${widget.postTitle}의 댓글",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // 게시물 상세 화면으로 이동 (라우팅 예시)
                      Navigator.pushNamed(context, '/postDetail', arguments: {
                        'postTitle': widget.postTitle,
                        'boardName': widget.boardName,
                      });
                    },
                    child: const Text(
                      "게시물 바로가기",
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// 메시지 전송 + DM방 문서 업데이트 (lastMessage, lastMessageTime 등)
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // messages 서브컬렉션에 새 메시지
    await messagesRef.add({
      'senderId': currentUser.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // privateMessages/{chatRoomId} 업데이트 (옵션)
    final dmDocRef = FirebaseFirestore.instance
        .collection('privateMessages')
        .doc(widget.chatRoomId);
    await dmDocRef.update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    // 입력창 비우고 스크롤 최하단으로
    _messageController.clear();
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  String _formatTimestamp(DateTime dt) {
    return "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }
}
