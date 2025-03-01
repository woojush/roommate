import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firebase 인증을 다룰 때 FirebaseAuth.instance를 여러 번 호출하지 않고, _auth를 통해 편하게 접근할 수 있도록 하는 코드
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Firestore 인증을 다룰 때 FirebaseFirestore.instance를 여러 번 호출하지 않고 _firestore를 통해 편하게 접근할 수 있도록 하는 코드

  // 로그인 처리: 아이디를 입력받아 Firestore에서 email을 조회 후 Firebase 로그인 수행
  static Future<void> login({required String id, required String password}) async { // login함수 정의.
    final query = await _firestore.collection('users') // firstore의 users 컬렉션에서
        .where('id', isEqualTo: id) // id 필드의 값과 login 함수 호출시의 id 값이 같은 걸 찾음.
        .limit(1) // 오직 한개의 데이터(id가 같은 유저의 데이터)만
        .get(); // 가져온다.
    // 이때 query는 QuerySnapshot 객체 → Firestore에서 검색한 전체 결과

    print(query.docs.map((doc) => doc.data()).toList());
    // 모든 검색된 데이터를 리스트 형태로 변환
    // 함수 호출시의 id와 백엔드에 저장된 id가 같은 유저의 정보들이 출력됨.


    if (query.docs.isEmpty) { // query.docs가 비어있다면
      throw Exception("존재하지 않는 아이디입니다.");
    }

    final email = query.docs.first['email'];

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
    String? profileImage, // 🟢 프로필 이미지 (선택 사항)
    String? dorm,         // 🟢 생활관
    String? roomType,     // 🟢 인실 정보
    String? dormDuration, // 🟢 기숙사 기간
  }) async {
    // Firebase Authentication에서 회원 생성
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String uid = userCredential.user!.uid;

    // Firestore에 사용자 정보 저장 (프로필 정보 포함)
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'id': id,
      'phone': phone,
      'birth': birth,
      'profileImage': profileImage ?? "", // 기본값 빈 문자열
      'dorm': dorm ?? "",                 // 기본값 빈 문자열
      'roomType': roomType ?? "",
      'dormDuration': dormDuration ?? "",
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🟢 사용자 정보 조회 (프로필 화면에서 사용)
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

  /// 🟢 프로필 업데이트 기능 추가
  static Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? profileImage,
    String? dorm,
    String? roomType,
    String? dormDuration,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        if (name != null) 'name': name,
        if (profileImage != null) 'profileImage': profileImage,
        if (dorm != null) 'dorm': dorm,
        if (roomType != null) 'roomType': roomType,
        if (dormDuration != null) 'dormDuration': dormDuration,
      });
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}
