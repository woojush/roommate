/// login_screen.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 사용자에게 로그인 UI를 제공하는 화면입니다.
/// - 아이디와 비밀번호 입력 필드를 제공하고,
///   로그인 버튼을 누르면 AccountService.login()을 호출하여 백엔드에서 로그인 처리를 수행합니다.
/// - 로그인 성공 시 메인 화면(MainScreen)으로 이동합니다.
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:findmate1/service/account/account_service.dart';
import 'package:findmate1/ui/account/signup_screen.dart';
import 'package:findmate1/ui/screens/main_screen.dart';
import 'package:findmate1/ui/account/find_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController(); // 아이디 입력받을 _idController 변수 생성
  final TextEditingController _passwordController = TextEditingController(); // 비번 입력받을 _passwordController 변수 생성
  bool _isLoading = false; // 로그인 요청 중인지 상태를 나타냄
  bool _isButtonActive = false; // 로그인 버튼 활성화 여부

  @override
  void initState() {
    super.initState();
    // 입력 필드 값 변경 감지하여 버튼 활성화 여부 업데이트
    _idController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
  }


  /// 입력값 유효성 검사 (둘 다 입력되면 버튼 활성화)
  /// 입력값 유효성 검사 (둘 다 입력되면 버튼 활성화)
  void _validateInputs() {
    setState(() {
      _isButtonActive = _idController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }



  /// 로그인 버튼 눌렀을 때, 백엔드 서비스(AccountService)를 호출하여 로그인 처리
  Future<void> _login() async { // 로그인 요청을 서버에 보내고 서버 응답을 기다려야 하기 때문에 Future과 async가 붙음.
    setState(() => _isLoading = true); // 서버에서 데이터를 가져오기 전까지는 로딩 is true.

    // try-catch : 서버 로그인 요청 중 문제가 발생하면, 앱이 멈추지 않고 사용자에게 오류 메시지를 보여주도록 도움.
    try {
      await AccountService.login( // AccountService : account_service.dart에서 정의됨.
        id: _idController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }catch (e) {
      _showErrorDialog();
    }


    setState(() => _isLoading = false);
  }

  /// 로그인 실패 시 AlertDialog 경고창 띄우기
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(20), // 내부 여백 조정
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "올바른 정보를 입력해주세요.",
              style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10,),
            const Divider(color: Colors.grey, thickness: 1), // 구분선 추가
            SizedBox(
              width: double.infinity, // 버튼을 하단에 꽉 차게 설정
              child: TextButton(
                onPressed: () => Navigator.pop(context), // 닫기 버튼
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent, // 배경색 투명
                  shape: const RoundedRectangleBorder(), // 기본 모양 유지
                ),
                child: const Text(
                  "닫기",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 120,),
            TextField(
              controller: _idController,
              cursorColor: Colors.black, // 입력 커서 색상을 검은색으로 변경
              style: TextStyle(color: Colors.black), // 입력 텍스트 색상을 검은색으로 변경
              onChanged: (value) {
                final String filtered = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''); // 영어 + 숫자만 허용
                if (value != filtered) {
                  _idController.value = TextEditingValue(
                    text: filtered,
                    selection: TextSelection.collapsed(offset: filtered.length), // 커서 위치 유지
                  );
                }
                _validateInputs(); // 버튼 활성화 상태 확인
              },
              decoration: InputDecoration(
                labelText: "아이디",
                labelStyle: TextStyle(color: Colors.grey), // 기본 상태에서 라벨 색상 회색
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.0), // 클릭 시 검은색 밑줄 강조
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0), // 기본 회색 밑줄 유지
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _passwordController,
              obscureText: true,
              cursorColor: Colors.black, // 입력 커서 색상을 검은색으로 변경
              style: TextStyle(color: Colors.black), // 입력 텍스트 색상을 검은색으로 변경
              onChanged: (value) {
                final String filtered = value.replaceAll(RegExp(r'[^a-zA-Z0-9!@#\$%^&*()_+={}\[\]:;<>,.?\/\\|-]'), ''); // ✅ 영어 + 숫자 + 특수문자만 허용
                if (value != filtered) {
                  _passwordController.value = TextEditingValue(
                    text: filtered,
                    selection: TextSelection.collapsed(offset: filtered.length), // 커서 위치 유지
                  );
                }
                _validateInputs(); // 버튼 활성화 상태 확인
              },
              decoration: InputDecoration(
                labelText: "비밀번호",
                labelStyle: TextStyle(color: Colors.grey), // 기본 상태에서 라벨 색상 회색
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.0), // 클릭 시 검은색 밑줄 강조
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0), // 기본 회색 밑줄 유지
                ),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 버튼을 양쪽 끝으로 정렬
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FindAccount()),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // 내부 패딩 제거
                    alignment: Alignment.centerLeft, // 텍스트 왼쪽 정렬
                  ),
                  child: const Text(
                    "아이디/비밀번호 찾기",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // 내부 패딩 제거
                    alignment: Alignment.centerRight, // 텍스트 오른쪽 정렬
                  ),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: (){}, child: Text('이용약관', style: TextStyle(color: Colors.black),)),
                TextButton(onPressed: (){}, child: Text('개인정보 처리방침', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: (){}, child: Text('문의하기', style: TextStyle(color: Colors.black))),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonActive ? _login : null, // 아이디 & 비밀번호가 입력되지 않으면 버튼 비활성화
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonActive ? Colors.red : Colors.grey, // 입력 여부에 따라 버튼 색상 변경
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.5), // 둥근 정도 조정 (값이 클수록 더 둥글어짐)
                      )
                  ),

                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("로그인", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),),
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
