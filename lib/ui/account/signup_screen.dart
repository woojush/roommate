/// signup_screen.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 사용자에게 회원가입 UI를 제공하는 화면입니다.
/// - 전화번호, 인증번호, 이메일, 이름, 생년월일, 아이디, 비밀번호 입력 필드를 포함합니다.
/// - 각 입력값의 중복 체크와 인증번호 처리는 UI에서 수행하고,
///   최종 회원가입 요청은 AccountService.signup()을 호출하여 백엔드에서 처리합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:findmate1/widgets/textFieldAndButton.dart'; // CustomInputButton 위젯 사용
import 'package:findmate1/service/account/account_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 입력 필드 컨트롤러들
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final _firestore = FirebaseFirestore.instance; // 중복 체크용 Firestore 인스턴스
  bool _isLoading = false;
  bool _isIdChecked = false;
  bool _isOtpSent = false;
  String _idCheckMessage = '';
  String _emailError = '';

  /// 아이디 중복 확인: Firestore에서 해당 아이디가 사용 중인지 확인
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

  /// 회원가입 완료: 모든 입력값 검증 후 AccountService.signup() 호출
  Future<void> _signup() async {
    if (!_validateInputs()) return;
    setState(() => _isLoading = true);
    try {
      await AccountService.signup(
        phone: _phoneController.text,
        birth: _birthController.text,
        id: _idController.text,
        password: _passwordController.text,
        email: _emailController.text,
        username: _nameController.text,
      );
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
    return true;
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

  // 인증번호 요청, 인증번호 확인 등 기타 함수는 필요에 따라 UI에 포함 (생략 가능)

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
              onPressed: _isLoading ? null : () => print("인증 요청 버튼 눌림"),
              buttonText: "인증 요청",
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r"\s")),
                LengthLimitingTextInputFormatter(13),
              ],
            ),
            CustomInputButton(
              controller: _otpController,
              labelText: "인증번호",
              onPressed: _isLoading ? null : () => print("인증 확인 버튼 눌림"),
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
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: '비밀번호')),
            TextButton(onPressed: _isLoading ? null : _signup, child: const Text('회원가입 완료'))
          ],
        ),
      ),
    );
  }
}
