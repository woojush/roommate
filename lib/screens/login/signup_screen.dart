import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:findmate1/widget/textFieldAndButton.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;
  bool _isLoading = false;
  bool _isIdChecked = false;
  bool _isOtpSent = false;
  String _idCheckMessage = '';
  String _emailError = '';

  /// 전화번호 중복 확인
  Future<void> _checkPhoneNumberExists() async {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: _phoneController.text)
        .get();
    if (query.docs.isNotEmpty) throw '이미 사용 중인 전화번호입니다.';
  }

  /// 아이디 중복 확인
  Future<void> _checkIdExists() async {
    final query = await _firestore
        .collection('users')
        .where('id', isEqualTo: _idController.text)
        .get();
    setState(() {
      if (query.docs.isNotEmpty) {
        _idCheckMessage = '이미 존재하는 아이디입니다.';
      } else {
        _idCheckMessage = '사용 가능한 아이디입니다!';
        _isIdChecked = true;
      }
    });
  }

  /// 인증번호 요청
  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    onPressed: _isLoading ? null : _sendOtp;
    try {
      await _checkPhoneNumberExists();
      await _auth.verifyPhoneNumber(
        phoneNumber: "+82${_phoneController.text.substring(1)}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw e.message ?? '인증번호 요청 실패';
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _showError(e.toString());
    }
    setState(() => _isLoading = false);
  }

  /// 인증번호 확인
  Future<void> _verifyOtp() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      return _showError("인증번호를 입력하세요.");
    }
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      await _auth.signInWithCredential(credential);
      _showSuccess("인증 성공!");
    } catch (e) {
      _showError("인증 실패: ${e.toString()}");
    }
  }

  /// 회원가입 완료
  /// 회원가입 완료
  Future<void> _signup() async {
    if (!_validateInputs()) return;
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Firebase Authentication에서 회원 생성
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 2️⃣ 생성된 UID 가져오기
      String uid = userCredential.user!.uid;

      // 3️⃣ Firestore에 사용자 정보 저장 (문서 ID를 UID로 설정)
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,  // UID 필드 추가 (문서 ID와 동일)
        'name': _nameController.text,
        'email': _emailController.text,
        'id': _idController.text,
        'phone': _phoneController.text,  // "+82" 없이 저장
        'birth': _birthController.text,  // "2005-11-21" 형식 유지
        'createdAt': FieldValue.serverTimestamp(), // 가입 시간 자동 저장
      });

      // 4️⃣ 회원가입 성공 후 로그인 화면으로 이동
      Navigator.pop(context);
    } catch (e) {
      _showError("회원가입 실패: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }


  /// 입력값 검증
  bool _validateInputs() {
    if (_phoneController.text.isEmpty) {
      _showError("전화번호를 입력하세요.");
      return false;
    }
    // if (!_isOtpSent) {
    //   _showError("인증번호를 요청하세요.");
    //   return false;
    // }
    // if (_verificationId == null) {
    //   _showError("전화번호 인증을 완료하세요.");
    //   return false;
    // }
    if (_birthController.text.isEmpty) {
      _showError("생년월일을 입력하세요.");
      return false;
    }
    if (_idController.text.isEmpty) {
      _showError("아이디를 입력하세요.");
      return false;
    }
    if (!_isIdChecked) {
      _showError("아이디 중복 체크를 해주세요.");
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError("비밀번호를 입력하세요.");
      return false;
    }
    return true; // 모든 검증 통과 시 true 반환
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomInputButton(
              controller: _phoneController,
              labelText: "전화번호 (01000000000)",
              //onPressed: _isLoading ? null : _sendOtp,
              onPressed: _isLoading
                  ? null
                  : () {
                print("입력된 전화번호: ${_phoneController.text}");
                print("변환된 전화번호: +82${_phoneController.text.substring(1)}");
                _sendOtp();
              },
              buttonText: "인증 요청",
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r"\s")),
                LengthLimitingTextInputFormatter(13),
              ],
            ),
            CustomInputButton(
              controller: _otpController,
              labelText: "인증번호",
              onPressed: _isLoading ? null : _verifyOtp,
              buttonText: "인증 확인",
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r"\s")),
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                errorText: _emailError.isNotEmpty ? _emailError : null,
              ),
              onChanged: (value) {
                setState(() {
                  _emailError = value.contains('@') ? '' : '올바른 이메일을 입력하세요.';
                });
              },
            ),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "이름")),
            TextField(
              controller: _birthController,
              decoration: const InputDecoration(labelText: "생년월일 (YYYY-MM-DD)"),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            ),
            CustomInputButton(
              controller: _idController,
              labelText: "아이디",
              onPressed: _checkIdExists,
              buttonText: "중복 확인",
            ),
            if (_idCheckMessage.isNotEmpty)
              Text(
                _idCheckMessage,
                style: TextStyle(color: _idCheckMessage.contains("가능") ? Colors.green : Colors.red),
              ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            TextButton(onPressed: _isLoading ? null : _signup, child: const Text('회원가입 완료'))
          ],
        ),
      ),
    );
  }
}
