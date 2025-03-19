// lib/service/tabs/matching/room/room_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room_model.dart';
import 'package:findmate1/service/tabs/chat/chat_service.dart';

class RoomService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const String roomsCollection = 'rooms';
  static const String checklistsCollection = 'checklists';

  /// 현재 사용자(User)의 체크리스트 데이터를 가져옵니다.
  static Future<Map<String, dynamic>?> fetchUserChecklist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await firestore.collection(checklistsCollection).doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Firestore에서 단일 방 정보를 가져와 RoomModel로 변환합니다.
  static Future<RoomModel?> fetchRoom(String roomId) async {
    try {
      final doc = await firestore.collection(roomsCollection).doc(roomId).get();
      if (!doc.exists) return null;
      return RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print("방 정보 불러오기 오류: $e");
      return null;
    }
  }

  /// Firestore에서 방 목록을 가져옵니다.
  static Future<List<RoomModel>> fetchRooms() async {
    final snapshot = await firestore.collection(roomsCollection).get();
    return snapshot.docs
        .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// 방 생성과 동시에 채팅방도 생성하여 연동합니다.
  /// 또한, 방 생성 시 현재 사용자가 이전에 참여 요청한 모든 방에서 자신의 요청을 삭제합니다.
  static Future<bool> createRoom({
    required String title,
    required String description,
    required String dorm,
    required String roomType,
    required String gender,
    required String dormDuration,
    int maxMembers = 2,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      // 1) rooms 컬렉션에 방 문서 생성
      DocumentReference roomRef = await firestore.collection(roomsCollection).add({
        'title': title,
        'description': description,
        'dorm': dorm,
        'roomType': roomType,
        'gender': gender,
        'dormDuration': dormDuration,
        'ownerUid': user.uid,
        'members': [user.uid],
        'joinRequests': [],
        'createdAt': FieldValue.serverTimestamp(),
        'views': 0,
        'maxMembers': maxMembers,
      });
      final roomId = roomRef.id;

      // 2) 채팅방 생성: ChatService.createChatRoom 호출
      final chatService = ChatService();
      final chatRoomId = await chatService.createChatRoom(title);
      print("생성된 chatRoomId: $chatRoomId"); // 디버깅 로그

      // 3) 생성된 채팅방 ID를 방 문서의 chatRoomId 필드에 저장
      await roomRef.update({
        'chatRoomId': chatRoomId,
      });

      // 4) 현재 사용자가 이전에 요청한 모든 방의 참여 요청 삭제
      final querySnapshot = await firestore
          .collection(roomsCollection)
          .where('joinRequests', arrayContains: user.uid)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.update({
          'joinRequests': FieldValue.arrayRemove([user.uid])
        });
      }

      print("✅ 방 및 채팅방 생성 완료, 방ID: $roomId, 채팅방ID: $chatRoomId");
      return true;
    } catch (e) {
      print("🚨 방 생성 오류: $e");
      return false;
    }
  }

  /// 현재 사용자를 반환합니다.
  static Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  /// 현재 사용자가 어떤 방에 참여 중인지 확인합니다.
  static Future<bool> isUserInRoom() async {
    final user = await getCurrentUser();
    if (user == null) return false;
    final snapshot = await firestore
        .collection(roomsCollection)
        .where('members', arrayContains: user.uid)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// 룸메 신청을 처리합니다.
  static Future<bool> requestJoin(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await firestore.collection(roomsCollection).doc(roomId).update({
        'joinRequests': FieldValue.arrayUnion([user.uid])
      });
      await firestore
          .collection(roomsCollection)
          .doc(roomId)
          .collection('joinRequests')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'requestedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("방 참여 요청 오류: $e");
      return false;
    }
  }

  /// 신청된 사용자를 승인합니다.
  static Future<void> approveUser(String roomId, String applicantUid) async {
    try {
      final roomRef = firestore.collection(roomsCollection).doc(roomId);
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(roomRef);
        if (!snapshot.exists) return;
        transaction.update(roomRef, {
          'members': FieldValue.arrayUnion([applicantUid]),
          'joinRequests': FieldValue.arrayRemove([applicantUid])
        });
      });
      await firestore
          .collection(roomsCollection)
          .doc(roomId)
          .collection('joinRequests')
          .doc(applicantUid)
          .delete();
    } catch (e) {
      print("방 참여 승인 오류: $e");
    }
  }

  /// 신청된 사용자를 거절합니다.
  static Future<void> rejectUser(String roomId, String applicantUid) async {
    try {
      final roomRef = firestore.collection(roomsCollection).doc(roomId);
      await roomRef.update({
        'joinRequests': FieldValue.arrayRemove([applicantUid])
      });
      await firestore
          .collection(roomsCollection)
          .doc(roomId)
          .collection('joinRequests')
          .doc(applicantUid)
          .delete();
    } catch (e) {
      print("방 참여 거절 오류: $e");
    }
  }

  /// 방을 삭제합니다.
  static Future<bool> deleteRoom(String roomId) async {
    try {
      await firestore.collection(roomsCollection).doc(roomId).delete();
      return true;
    } catch (e) {
      print("방 삭제 오류: $e");
      return false;
    }
  }

  /// 방 정보를 업데이트합니다.
  static Future<bool> updateRoomInfo({
    required String roomId,
    required String title,
    required String description,
  }) async {
    try {
      await firestore.collection(roomsCollection).doc(roomId).update({
        'title': title,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("방 정보 업데이트 오류: $e");
      return false;
    }
  }

  /// 방을 나갑니다.
  static Future<bool> leaveRoom(String roomId, String userId) async {
    try {
      await firestore.collection(roomsCollection).doc(roomId).update({
        'members': FieldValue.arrayRemove([userId])
      });
      return true;
    } catch (e) {
      print("방 나가기 오류: $e");
      return false;
    }
  }

  /// 방의 현재 멤버 수를 반환합니다.
  static Future<int> getRoomMemberCount(String roomId) async {
    try {
      final doc = await firestore.collection(roomsCollection).doc(roomId).get();
      if (doc.exists) {
        List<dynamic> members = doc.data()?['members'] ?? [];
        return members.length;
      }
    } catch (e) {
      print("방 멤버 수 가져오기 오류: $e");
    }
    return 0;
  }

  /// 방이 꽉 찼는지 여부를 확인합니다.
  static Future<bool> isRoomFull(String roomId) async {
    try {
      final doc = await firestore.collection(roomsCollection).doc(roomId).get();
      if (doc.exists) {
        int currentMembers = (doc.data()?['members'] as List<dynamic>?)?.length ?? 0;
        int maxMembers = doc.data()?['maxMembers'] ?? 0;
        return currentMembers >= maxMembers;
      }
    } catch (e) {
      print("방이 꽉 찼는지 확인하는 중 오류 발생: $e");
    }
    return false;
  }

  /// 방 조회수를 증가시킵니다.
  static Future<void> incrementRoomViews(String roomId) async {
    final roomRef = firestore.collection(roomsCollection).doc(roomId);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>?;
      int currentViews = data?['views'] ?? 0;
      transaction.update(roomRef, {'views': currentViews + 1});
    });
  }
}
