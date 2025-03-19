import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:findmate1/widgets/textFieldAndButton.dart'; // CustomInputButton 위젯 사용
import 'package:findmate1/service/account/account_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmate1/widgets/main_tab_appbar.dart';

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
  bool _isEmailChecked = false;
  String _idCheckMessage = '';
  String _emailCheckMessage = '';

  /// 아이디 중복 확인: Firestore에서 해당 아이디가 사용 중인지 확인
  Future<void> _checkIdExists() async {
    final query = await _firestore
        .collection('users')
        .where('id', isEqualTo: _idController.text)
        .get();
    setState(() {
      if (query.docs.isNotEmpty) {
        _idCheckMessage = '이미 존재하는 아이디입니다.';
        _isIdChecked = false;
      } else {
        _idCheckMessage = '사용 가능한 아이디입니다!';
        _isIdChecked = true;
      }
    });
  }

  /// 이메일 중복 확인: Firestore에서 해당 이메일이 사용 중인지 확인
  Future<void> _checkEmailExists() async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: _emailController.text)
        .get();
    setState(() {
      if (query.docs.isNotEmpty) {
        _emailCheckMessage = '이미 사용 중인 이메일입니다.';
        _isEmailChecked = false;
      } else {
        _emailCheckMessage = '사용 가능한 이메일입니다!';
        _isEmailChecked = true;
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
        userName: _nameController.text,
      );
      Navigator.pop(context);
    } catch (e) {
      _showError("회원가입 실패: ${e.toString()}");
    }
    setState(() => _isLoading = false);
  }

  /// 입력값 검증: 각 필드의 값이 올바른지, 아이디와 이메일 중복 확인을 완료했는지 체크합니다.
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
    if (_emailController.text.isEmpty) {
      _showError("이메일을 입력하세요.");
      return false;
    }
    // 기본적인 이메일 형식 검증
    if (!_emailController.text.contains('@')) {
      _showError("올바른 이메일을 입력하세요.");
      return false;
    }
    if (!_isEmailChecked) {
      _showError("이메일 중복 체크를 해주세요.");
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError("비밀번호를 입력하세요.");
      return false;
    }
    return true;
  }

  /// 오류 메시지를 스낵바로 표시합니다.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// 성공 메시지를 스낵바로 표시합니다.
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTabAppBar(title: "회원가입"),
      body: SingleChildScrollView(
        child: Padding(
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
              // 이메일 입력 및 중복 확인 버튼
              CustomInputButton(
                controller: _emailController,
                labelText: "이메일",
                onPressed: _checkEmailExists,
                buttonText: "중복 확인",
              ),
              if (_emailCheckMessage.isNotEmpty)
                Text(
                  _emailCheckMessage,
                  style: TextStyle(
                    color: _emailCheckMessage.contains("사용 가능한") ? Colors.green : Colors.red,
                  ),
                ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "이름"),
              ),
              TextField(
                controller: _birthController,
                decoration: const InputDecoration(labelText: "생년월일 (YYYY-MM-DD)"),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              ),
              // 아이디 입력 및 중복 확인 버튼
              CustomInputButton(
                controller: _idController,
                labelText: "아이디",
                onPressed: _checkIdExists,
                buttonText: "중복 확인",
              ),
              if (_idCheckMessage.isNotEmpty)
                Text(
                  _idCheckMessage,
                  style: TextStyle(
                      color: _idCheckMessage.contains("사용 가능한") ? Colors.green : Colors.red),
                ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
              ),
              TextButton(onPressed: _isLoading ? null : _signup, child: const Text('회원가입 완료'))
            ],
          ),
        ),
      ),
    );
  }
}
