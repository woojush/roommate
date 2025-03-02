/// room_service.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 방과 관련된 Firestore 데이터 처리 및 룸메 매칭 알고리즘을 담당합니다.
/// - 사용자의 체크리스트 데이터를 가져와 1차 필터링 수행
/// - 방 목록을 가져와 사용자의 우선순위에 맞춰 매칭 점수를 계산하여 정렬
/// - 사용자가 방을 생성하거나 참여하는 기능 제공
/// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/service/tabs/matching/room_model.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🟢 사용자의 체크리스트 데이터를 Firestore에서 가져오기
  static Future<Map<String, dynamic>?> fetchUserChecklist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('checklists')
        .doc(user.uid)
        .get();

    return doc.exists ? doc.data() : null;
  }

  /// 🟢 Firestore에서 방 목록 가져오기
  static Stream<QuerySnapshot> fetchRooms() {
    return FirebaseFirestore.instance.collection('rooms').snapshots();
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

  /// 🟢 2차 필터링: 사용자의 우선순위를 기반으로 방 매칭 점수 계산
  static int calculateMatchScore(Map<String, dynamic> userChecklist, RoomModel room) {
    int score = 0;
    List<String> priorities = userChecklist['priority'] ?? [];

    for (String priority in priorities) {
      if (room.checklist.containsKey(priority) &&
          room.checklist[priority] == userChecklist[priority]) {
        score += 1;
      }
    }

    return score;
  }

  /// 🟢 방 생성 기능
  static Future<bool> createRoom({
    required String title,
    required String description,
    required String dorm,
    required String roomType,
    required String gender,
    required String dormDuration,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      await FirebaseFirestore.instance.collection('rooms').add({
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
      return true;
    } catch (e) {
      print("방 생성 오류: $e");
      return false;
    }
  }

  /// 🟢 특정 방의 정보를 Firestore에서 가져오기
  static Future<RoomModel?> fetchRoom(String roomId) async {
    final doc = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      return RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
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
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .update({
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
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'members': FieldValue.arrayUnion([applicantUid]),
      'joinRequests': FieldValue.arrayRemove([applicantUid])
    });
  }

  /// 🟢 방 참여 거절
  static Future<void> rejectUser(String roomId, String applicantUid) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'joinRequests': FieldValue.arrayRemove([applicantUid])
    });
  }
}
