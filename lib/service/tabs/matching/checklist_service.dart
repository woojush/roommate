/// ---------------------------------------------------------------------------
/// 이 파일은 체크리스트 데이터를 Firestore에 저장하거나 조회하는
/// 백엔드 로직을 담당합니다. UI에서는 ChecklistService의 saveChecklist()
/// 메서드를 호출하여 데이터 저장 작업을 수행합니다.
///
/// 나중에 특정 체크리스트 필터 기능(예: alarm == "잠만보") 등을 추가하기 위해,
/// checklist 데이터를 최상위 컬렉션 "checklists"에 {uid} 문서로 저장합니다.
/// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChecklistService {

  static Future<DocumentSnapshot> fetchRoom(String roomId) async {
    return await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
  }

  static Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<bool> requestJoin(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'requests': FieldValue.arrayUnion([user.uid])
      });
      return true;
    } catch (e) {
      print("방 참여 요청 실패: $e");
      return false;
    }
  }

  static Future<void> approveUser(String roomId, String applicantUid) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'members': FieldValue.arrayUnion([applicantUid]),
      'requests': FieldValue.arrayRemove([applicantUid])
    });
  }

  static Future<void> rejectUser(String roomId, String applicantUid) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'requests': FieldValue.arrayRemove([applicantUid])
    });
  }

  /// 체크리스트 응답(Map<String, dynamic>)을
  /// 상위 컬렉션 "checklists"에 doc(uid)로 저장.
  static Future<void> saveChecklist(Map<String, dynamic> responses) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // 유저 인증 정보 없음

    try {
      // "checklists/{uid}" 문서 생성/업데이트
      await FirebaseFirestore.instance
          .collection("checklists")
          .doc(user.uid)
          .set(responses, SetOptions(merge: true));
    } catch (e) {
      print("체크리스트 저장 실패: $e");
      throw Exception("체크리스트 저장에 실패했습니다.");
    }
  }
}


