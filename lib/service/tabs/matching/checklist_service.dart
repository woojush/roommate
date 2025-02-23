/// ---------------------------------------------------------------------------
/// 이 파일은 체크리스트 데이터를 Firestore에 저장하거나 조회하는
/// 백엔드 로직을 담당합니다. UI에서는 ChecklistService의 saveChecklist()
/// 메서드를 호출하여 데이터 저장 작업을 수행합니다.
/// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChecklistService {
  static Future<void> saveChecklist(Map<String, dynamic> responses) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("checklist")
          .doc("latest")
          .set(responses);
    } catch (e) {
      print("체크리스트 저장 실패: $e");
      throw Exception("체크리스트 저장에 실패했습니다.");
    }
  }
}
