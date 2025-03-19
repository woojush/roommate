import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 채팅방 생성
  /// - 방 생성 시 현재 사용자를 참여자로 추가합니다.
  Future<String> createChatRoom(String roomName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final docRef = await _firestore.collection('chatRooms').add({
      'roomName': roomName,
      'owner': currentUser.uid,
      'participants': [currentUser.uid],
      'joinRequests': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// 채팅방 참여 요청
  /// - 사용자가 채팅방에 참여 요청을 보냅니다.
  Future<void> requestJoinChatRoom(String roomId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final roomRef = _firestore.collection('chatRooms').doc(roomId);
    final roomSnapshot = await roomRef.get();
    if (!roomSnapshot.exists) {
      throw Exception("Chat room not found");
    }

    final data = roomSnapshot.data() as Map<String, dynamic>;
    final List<dynamic> joinRequests = data['joinRequests'] ?? [];
    final List<dynamic> participants = data['participants'] ?? [];

    // 이미 참가 중이거나, 이미 요청한 경우 아무 작업도 하지 않음
    if (participants.contains(currentUser.uid)) return;
    if (joinRequests.contains(currentUser.uid)) return;

    await roomRef.update({
      'joinRequests': FieldValue.arrayUnion([currentUser.uid]),
    });
  }

  /// 방장이 참여 요청을 승인할 때 호출
  /// - 요청한 사용자를 채팅방 참가자로 추가하고, 요청 목록에서 제거합니다.
  Future<void> approveJoinRequest(String roomId, String userId) async {
    final roomRef = _firestore.collection('chatRooms').doc(roomId);
    await roomRef.update({
      'joinRequests': FieldValue.arrayRemove([userId]),
      'participants': FieldValue.arrayUnion([userId]),
    });
  }

  /// 메시지 전송
  /// - 지정된 채팅방에 메시지를 추가합니다.
  Future<void> sendMessage(String roomId, String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .add({
      'senderId': currentUser.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 실시간 메시지 스트림 반환
  /// - 지정된 채팅방의 메시지들을 시간순(오름차순)으로 스트리밍합니다.
  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessage.fromDocument(doc))
        .toList());
  }

  /// 채팅방 삭제 (메시지 서브컬렉션도 함께 삭제)
  Future<void> deleteChatRoom(String roomId) async {
    final roomRef = _firestore.collection('chatRooms').doc(roomId);

    // 메시지 서브컬렉션의 모든 문서 삭제
    final messagesSnapshot = await roomRef.collection('messages').get();
    for (final doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    // 채팅방 문서 삭제
    await roomRef.delete();
  }
}
