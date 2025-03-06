import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/service/tabs/matching/room/room_model.dart';

class RoomService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const String roomsCollection = 'rooms';
  static const String checklistsCollection = 'checklists';

  static Future<Map<String, dynamic>?> fetchUserChecklist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await firestore.collection(checklistsCollection).doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

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

  static Future<List<RoomModel>> fetchRooms() async {
    final snapshot = await firestore.collection(roomsCollection).get();
    return snapshot.docs
        .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((room) => !room.isFull())
        .toList();
  }

  static List<RoomModel> filterRooms(
      List<RoomModel> rooms, Map<String, dynamic> userChecklist) {
    return rooms.where((room) {
      return room.dorm == userChecklist['dorm'] &&
          room.roomType == userChecklist['roomType'] &&
          room.gender == userChecklist['gender'] &&
          room.dormDuration == userChecklist['dormDuration'];
    }).toList();
  }

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
      await firestore.collection(roomsCollection).add({
        'title': title,
        'description': description,
        'dorm': dorm,
        'roomType': roomType,
        'gender': gender,
        'dormDuration': dormDuration,
        'ownerUid': user.uid,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'views': 0,
        'maxMembers': maxMembers,
      });
      print("✅ 방 생성 완료");
      return true;
    } catch (e) {
      print("🚨 방 생성 오류: $e");
      return false;
    }
  }

  static Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<bool> isUserInRoom() async {
    final user = await getCurrentUser();
    if (user == null) return false;
    final snapshot = await firestore
        .collection(roomsCollection)
        .where('members', arrayContains: user.uid)
        .get();
    return snapshot.docs.isNotEmpty;
  }

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

  static Future<void> approveUser(String roomId, String applicantUid) async {
    await firestore.collection(roomsCollection).doc(roomId).update({
      'members': FieldValue.arrayUnion([applicantUid]),
      'joinRequests': FieldValue.arrayRemove([applicantUid])
    });
  }

  static Future<void> rejectUser(String roomId, String applicantUid) async {
    await firestore.collection(roomsCollection).doc(roomId).update({
      'joinRequests': FieldValue.arrayRemove([applicantUid])
    });
  }

  static Future<bool> deleteRoom(String roomId) async {
    try {
      await firestore.collection(roomsCollection).doc(roomId).delete();
      return true;
    } catch (e) {
      print("방 삭제 오류: $e");
      return false;
    }
  }

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

  static Future<void> incrementRoomViews(String roomId) async {
    final roomRef = firestore.collection(roomsCollection).doc(roomId);
    await firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(roomRef);
      if (!snapshot.exists) return;
      int currentViews = (snapshot['views'] ?? 0);
      transaction.update(roomRef, {'views': currentViews + 1});
    });
  }
}
