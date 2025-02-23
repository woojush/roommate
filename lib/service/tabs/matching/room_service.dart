/// ---------------------------------------------------------------------------
/// 이 파일은 매칭(룸) 관련 백엔드 로직을 담당하는 서비스 파일입니다.
/// - 사용자의 체크리스트 데이터를 조회
/// - 방 생성, 조회, 룸메 신청, 승인 및 거절 등의 Firestore 연동 작업을 수행합니다.
/// - Firebase Auth를 통해 현재 로그인한 사용자 정보도 관리합니다.
/// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room_model.dart';

class RoomService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 사용자 체크리스트 데이터를 Firestore에서 조회
  static Future<Map<String, dynamic>> fetchUserChecklist() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('checklist')
        .doc('latest')
        .get();
    return doc.exists ? doc.data() as Map<String, dynamic> : {};
  }

  /// 방 생성: 데이터를 Firestore에 저장
  static Future<bool> createRoom({
    required String title,
    required String description,
    required String dorm,
    required String roomType,
    required String gender,
    required String dormDuration,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    // 중복 여부 체크 등은 생략
    try {
      await _firestore.collection('rooms').add({
        'title': title,
        'description': description,
        'dorm': dorm,
        'roomType': roomType,
        'gender': gender,
        'dormDuration': dormDuration,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [user.uid],
      });
      return true;
    } catch (e) {
      print("방 생성 실패: $e");
      return false;
    }
  }

  /// 방 데이터 조회
  static Future<Map<String, dynamic>?> fetchRoom(String roomId) async {
    DocumentSnapshot doc = await _firestore.collection('rooms').doc(roomId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  /// 현재 로그인한 사용자 반환
  static Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  /// 룸메 신청
  static Future<bool> requestJoin(String roomId) async {
    User? user = _auth.currentUser;
    if (user == null) return false;
    // 중복 방 가입 여부 체크는 생략
    try {
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('requests')
          .doc(user.uid)
          .set({'status': 'pending'});
      return true;
    } catch (e) {
      print("룸메 신청 실패: $e");
      return false;
    }
  }

  /// 신청 승인
  static Future<void> approveUser(String roomId, String applicantUid) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('requests')
        .doc(applicantUid)
        .update({'status': 'accepted'});
    await _firestore.collection('rooms').doc(roomId).update({
      'members': FieldValue.arrayUnion([applicantUid])
    });
  }

  /// 신청 거절
  static Future<void> rejectUser(String roomId, String applicantUid) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('requests')
        .doc(applicantUid)
        .update({'status': 'rejected'});
  }

  /// 추가적으로 방 목록 조회, 중복 체크 등도 구현 가능
  static Stream<QuerySnapshot> fetchRooms(Map<String, dynamic> checklist) {
    return _firestore.collection('rooms')
        .where('dorm', isEqualTo: checklist['dorm'])
        .where('roomType', isEqualTo: checklist['roomType'])
        .where('gender', isEqualTo: checklist['gender'])
        .where('dormDuration', isEqualTo: checklist['dormDuration'])
        .snapshots();
  }
}
