/// account_service.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 로그인, 로그아웃, 회원가입과 관련된 백엔드 로직을 담당하는
/// 서비스 파일입니다.
/// - login(): 사용자 아이디를 기반으로 Firestore에서 email을 조회한 후,
///            Firebase Authentication을 통해 로그인 처리합니다.
/// - logout(): Firebase Authentication을 통해 로그아웃 처리합니다.
/// - signup(): Firebase Authentication으로 회원을 생성하고, 추가적인 사용자 정보를
///             Firestore에 저장합니다.
/// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 로그인 처리: 아이디를 입력받아 Firestore에서 email 조회 후 Firebase 로그인 수행
  static Future<void> login({required String id, required String password}) async {
    // Firestore에서 'id' 필드로 이메일 조회
    final query = await _firestore.collection('users')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("존재하지 않는 아이디입니다.");
    }

    final email = query.docs.first['email'];

    // Firebase Authentication으로 로그인 시도
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// 로그아웃 처리: Firebase Authentication을 통해 로그아웃
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// 회원가입 처리: Firebase Authentication으로 회원 생성 후, Firestore에 사용자 정보 저장
  static Future<void> signup({
    required String phone,
    required String birth,
    required String id,
    required String password,
    required String email,
    required String name,
  }) async {
    // 1. Firebase Authentication에서 회원 생성
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String uid = userCredential.user!.uid;

    // 2. Firestore에 사용자 정보 저장 (문서 ID를 UID로 사용)
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'id': id,
      'phone': phone,         // "+82" 없이 저장 (전화번호 형식은 상황에 맞게 조정)
      'birth': birth,         // 예: "2005-11-21"
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
