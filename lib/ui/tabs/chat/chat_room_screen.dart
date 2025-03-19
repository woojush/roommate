import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/service/tabs/chat/chat_model.dart';
import 'package:findmate1/service/tabs/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  // 전달받은 roomId는 chatRooms 컬렉션의 문서 ID입니다.
  final String roomId;
  final String roomName;
  const ChatRoomScreen({
    Key? key,
    required this.roomId,
    required this.roomName,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _roomExists = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfRoomExists();
  }

  Future<void> _checkIfRoomExists() async {
    final roomId = widget.roomId;
    print('ChatRoomScreen - 확인할 roomId: $roomId');
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(roomId)
          .get();
      if (!doc.exists) {
        print('채팅방 문서를 찾지 못했습니다: $roomId');
        setState(() {
          _roomExists = false;
          _isLoading = false;
        });
      } else {
        print('채팅방 문서 확인됨: $roomId');
        setState(() {
          _roomExists = true;
          _isLoading = false;
        });
        _joinChatRoomIfNeeded();
      }
    } catch (e) {
      print('채팅방 확인 중 오류 발생: $e');
      setState(() {
        _roomExists = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _joinChatRoomIfNeeded() async {
    try {
      await _chatService.requestJoinChatRoom(widget.roomId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 메시지 전송
    await _chatService.sendMessage(widget.roomId, text);
    _messageController.clear();
    // 애니메이션 없이 바로 최하단으로 이동
    await Future.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Widget _buildParticipantsView() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("에러 발생: ${snapshot.error}"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final doc = snapshot.data!;
        if (!doc.exists) return Center(child: Text("채팅방을 찾을 수 없습니다."));
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic> participants = data['participants'] ?? [];
        if (participants.isEmpty) return Center(child: Text("아직 참여자가 없습니다."));
        return ListView.builder(
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participantId = participants[index].toString();
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(participantId),
            );
          },
        );
      },
    );
  }

  Widget _buildChatBody() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _chatService.getMessages(widget.roomId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("메시지 로딩 오류: ${snapshot.error}"));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final messages = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == FirebaseAuth.instance.currentUser?.uid;
                  final timeStr = DateFormat('HH:mm').format(msg.timestamp.toDate());
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.indigo : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeStr,
                            style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // 메시지 입력창
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "메시지를 입력하세요",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFoundView() {
    return Center(
      child: Text(
        "채팅방을 찾을 수 없습니다.",
        style: TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.roomName),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(child: SafeArea(child: _buildParticipantsView())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _roomExists
          ? _buildChatBody()
          : _buildNotFoundView(),
    );
  }
}
