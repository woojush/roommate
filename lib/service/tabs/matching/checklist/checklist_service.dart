/// ---------------------------------------------------------------------------
/// Firestore와 데이터베이스 연동 (데이터 저장 및 불러오기)
/// UI에서는 ChecklistService의 saveChecklist() 메서드를 호출하여 데이터 저장 작업을 수행합니다.
/// 나중에 특정 체크리스트 필터 기능(예: alarm == "잠만보") 등을 추가하기 위해,
/// checklist 데이터를 최상위 컬렉션 "checklists"에 {uid} 문서로 저장합니다.
///
/// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChecklistService {
  // Firestore에서 특정 room(방)에 대한 정보를 가져오거나,
  // 사용자의 방 참여 요청을 처리하는 역할.

  static Future<DocumentSnapshot> fetchRoom(String roomId) async {
    // 특정 방 정보 가져오기
    // Firestore에서 특정 방(roomId)의 정보를 가져오기 위해 사용됨.
    return await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
  }

  static Future<User?> getCurrentUser() async {
    // 현재 로그인한 사용자 정보 가져오기.
    return FirebaseAuth.instance.currentUser;
  }

  static Future<bool> requestJoin(String roomId) async {
    // 특정 방에 참여 요청 보내기
    final user = FirebaseAuth.instance.currentUser;
    // 현재 로그인한 사용자 정보를 가져옴.
    if (user == null) return false; // 로그인한 사용자가 없으면 요청 불가
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

  // saveChecklist 클래스 생성해야함.

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

  /// 체크리스트 응답(Map<String, dynamic>)을 상위 컬렉션 "checklists"에 doc(uid)로 저장.
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


