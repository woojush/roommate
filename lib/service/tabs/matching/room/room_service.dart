/// ---------------------------------------------------------------------------
/// 이 파일은 방과 관련된 Firestore 데이터 처리 및 룸메 매칭 알고리즘을 담당합니다.
/// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/service/tabs/matching/room/room_model.dart';

class RoomService {
  // Firestore 인스턴스와 컬렉션 이름을 상수로 관리
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const String roomsCollection = 'rooms';
  static const String checklistsCollection = 'checklists';

  /// 🟢 사용자의 체크리스트 데이터를 Firestore에서 가져오기
  static Future<Map<String, dynamic>?> fetchUserChecklist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await firestore.collection(checklistsCollection).doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// 🟢 Firestore에서 특정 방 정보 가져오기
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

  /// 🟢 Firestore에서 전체 방 목록 가져오기
  static Future<List<RoomModel>> fetchRooms() async {
    final snapshot = await firestore.collection(roomsCollection).get();
    return snapshot.docs
        .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((room) => !room.isFull()) // 방이 꽉 찬 경우 제외
        .toList();
  }

  /// 🟢 1차 필터링: 생활관, 성별, 기숙사 기간, 인실이 같은 방만 선택
  static List<RoomModel> filterRooms(
      List<RoomModel> rooms, Map<String, dynamic> userChecklist) {
    return rooms.where((room) {
      return room.dorm == userChecklist['dorm'] &&
          room.roomType == userChecklist['roomType'] &&
          room.gender == userChecklist['gender'] &&
          room.dormDuration == userChecklist['dormDuration'];
    }).toList();
  }

  /// 🟢 방 생성 기능
  static Future<bool> createRoom({
    required String title,
    required String description,
    required String dorm,
    required String roomType,
    required String gender,
    required String dormDuration,
    required int maxMembers,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // 1. Firestore에 문서 생성 (views & maxMembers 필드 제외)
      DocumentReference roomRef = await firestore.collection(roomsCollection).add({
        'title': title,
        'description': description,
        'dorm': dorm,
        'roomType': roomType,
        'gender': gender,
        'dormDuration': dormDuration,
        'ownerUid': user.uid,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. 생성된 문서에 조회수와 최대 인원 필드 추가
      await roomRef.update({
        'views': 0,
        'maxMembers': maxMembers,
      });

      print("✅ 방 생성 완료: ${roomRef.id}");
      return true;
    } catch (e) {
      print("🚨 방 생성 오류: $e");
      return false;
    }
  }

  /// 🟢 현재 로그인한 사용자 정보 가져오기
  static Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  /// 🟢 방 참여 요청
  static Future<bool> requestJoin(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await firestore.collection(roomsCollection).doc(roomId).update({
        'joinRequests': FieldValue.arrayUnion([user.uid])
      });
      return true;
    } catch (e) {
      print("방 참여 요청 오류: $e");
      return false;
    }
  }

  /// 🟢 방 참여 승인
  static Future<void> approveUser(String roomId, String applicantUid) async {
    await firestore.collection(roomsCollection).doc(roomId).update({
      'members': FieldValue.arrayUnion([applicantUid]),
      'joinRequests': FieldValue.arrayRemove([applicantUid])
    });
  }

  /// 🟢 방 참여 거절
  static Future<void> rejectUser(String roomId, String applicantUid) async {
    await firestore.collection(roomsCollection).doc(roomId).update({
      'joinRequests': FieldValue.arrayRemove([applicantUid])
    });
  }

  /// 🟢 방 삭제 기능
  static Future<bool> deleteRoom(String roomId) async {
    try {
      await firestore.collection(roomsCollection).doc(roomId).delete();
      return true;
    } catch (e) {
      print("방 삭제 오류: $e");
      return false;
    }
  }

  /// 🟢 방 정보 업데이트
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

  /// 🟢 방 나가기 기능
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

  /// 🟢 현재 방의 멤버 수 가져오기
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

  /// 🟢 방이 꽉 찼는지 확인
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
}

/// 🟢 RoomViews: Firestore에서 조회수 업데이트를 원자적으로 수행하는 클래스
class RoomViews {
  static Future<void> increment(String roomId) async {
    final roomRef = FirebaseFirestore.instance.collection(RoomService.roomsCollection).doc(roomId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(roomRef);
      if (!snapshot.exists) return;
      int currentViews = (snapshot['views'] ?? 0);
      transaction.update(roomRef, {'views': currentViews + 1});
    });
  }
}
