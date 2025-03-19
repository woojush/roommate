import 'package:cloud_firestore/cloud_firestore.dart';

/// 채팅방 정보 모델
class ChatRoom {
  final String id;
  final String roomName;
  final String owner; // 방장 UID
  final List<String> participants;
  final List<String> joinRequests;
  final Timestamp createdAt;

  ChatRoom({
    required this.id,
    required this.roomName,
    required this.owner,
    required this.participants,
    required this.joinRequests,
    required this.createdAt,
  });

  factory ChatRoom.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      roomName: data['roomName'] ?? '',
      owner: data['owner'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      joinRequests: List<String>.from(data['joinRequests'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomName': roomName,
      'owner': owner,
      'participants': participants,
      'joinRequests': joinRequests,
      'createdAt': createdAt,
    };
  }
}

/// 채팅 메시지 정보 모델
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
