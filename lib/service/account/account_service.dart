import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 로그인 처리: 아이디를 입력받아 Firestore에서 email을 조회 후 Firebase 로그인 수행
  static Future<void> login({required String id, required String password}) async {
    final query = await _firestore.collection('users')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    print(query.docs.map((doc) => doc.data()).toList());

    if (query.docs.isEmpty) {
      throw Exception("존재하지 않는 아이디입니다.");
    }

    final email = query.docs.first['email'];
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// 계정 삭제: 현재 로그인된 계정의 Firestore 데이터 삭제 후, Firebase Auth에서 계정 삭제
  static Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("로그인된 계정이 없습니다.");
    }
    // Firestore에서 사용자 데이터 삭제
    await _firestore.collection('users').doc(user.uid).delete();
    // Firebase Auth에서 계정 삭제
    await user.delete();
  }


  /// 로그아웃 처리
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// 회원가입 처리: Firebase Authentication으로 회원 생성 후, Firestore에 사용자 기본 정보만 저장
  static Future<void> signup({
    required String phone,
    required String birth,
    required String id,
    required String password,
    required String email,
    required String userName,
  }) async {
    // Firebase Authentication에서 회원 생성
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String uid = userCredential.user!.uid;

    // Firestore에 사용자 정보 저장 (체크리스트 관련 정보는 따로 관리)
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'userName': userName,
      'email': email,
      'id': id,
      'phone': phone,
      'birth': birth,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 사용자 정보 조회 (프로필 화면에서 사용)
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  /// 프로필 업데이트 기능
  static Future<void> updateUserProfile({
    required String uid,
    String? userName,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        if (userName != null) 'userName': userName,
      });
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}
