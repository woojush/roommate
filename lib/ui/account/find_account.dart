import 'package:flutter/material.dart';
import 'package:findmate1/widgets/sub_screen_appbar.dart';
// 기본 계정 서비스는 필요한 경우에만 사용하고,
// 아이디/비밀번호 찾기 기능은 find_account_service.dart에 정의되어 있으므로 alias를 이용합니다.
import 'package:findmate1/service/account/account_service.dart';
import 'package:findmate1/service/account/find_account_service.dart' as findAccount;

class FindAccount extends StatefulWidget {
  const FindAccount({super.key});

  @override
  State<FindAccount> createState() => _FindAccountState();
}

class _FindAccountState extends State<FindAccount> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _idEmailController = TextEditingController(); // 아이디 찾기 입력창 (이메일)
  final TextEditingController _pwEmailController = TextEditingController(); // 비밀번호 찾기 입력창 (아이디)
  int _selectedTabIndex = 0; // 현재 선택된 탭 인덱스 (0: 아이디 찾기, 1: 비밀번호 찾기)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 탭 변경 감지하여 입력값 초기화 & AppBar 제목 변경
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
        _clearInputFields();
      });
      print("현재 선택된 탭 인덱스: $_selectedTabIndex");
    });
  }

  /// 탭 변경 시 입력값 초기화
  void _clearInputFields() {
    if (_selectedTabIndex == 0) {
      _pwEmailController.clear();
      print("비밀번호 입력 필드 초기화");
    } else {
      _idEmailController.clear();
      print("이메일 입력 필드 초기화");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _idEmailController.dispose();
    _pwEmailController.dispose();
    super.dispose();
  }

  /// 아이디 찾기 - 입력값 필터 (영어, 숫자, @, . 허용)
  String _validateIdInput(String value) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9@.]*$');
    if (!regex.hasMatch(value)) {
      final newValue = value.replaceAll(RegExp(r'[^a-zA-Z0-9@.]'), '');
      print("잘못된 문자 제거 전: $value, 후: $newValue");
      return newValue;
    }
    return value;
  }

  /// 비밀번호 찾기 - 입력값 필터 (영어, 숫자만 허용)
  String _validatePwInput(String value) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]*$');
    if (!regex.hasMatch(value)) {
      final newValue = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      print("잘못된 문자 제거 전: $value, 후: $newValue");
      return newValue;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubScreenAppBar(
        title: _selectedTabIndex == 0 ? "아이디 찾기" : "비밀번호 찾기",
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "아이디 찾기"),
              Tab(text: "비밀번호 찾기"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFindIdTab(),
                _buildFindPasswordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "아이디 찾기" 탭 화면 (이메일 입력)
  Widget _buildFindIdTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _idEmailController,
            onChanged: (value) {
              _idEmailController.text = _validateIdInput(value);
              _idEmailController.selection = TextSelection.fromPosition(
                TextPosition(offset: _idEmailController.text.length),
              );
            },
            decoration: InputDecoration(
              hintText: "가입된 이메일",
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              print("아이디 찾기 버튼 눌림");
              final email = _idEmailController.text.trim();
              if (email.isEmpty) {
                _showMessage("이메일을 입력해주세요.");
                return;
              }
              try {
                // find_account_service.dart에 정의된 AccountService 사용
                final id = await findAccount.AccountService.findIdByEmail(email: email);
                if (mounted) {
                  _showMessage("회원님의 아이디는 [$id] 입니다.");
                }
                print("아이디 찾기 성공: $id");
              } catch (e) {
                if (mounted) {
                  _showMessage(e.toString());
                }
                print("아이디 찾기 실패: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("아이디 찾기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// "비밀번호 찾기" 탭 화면 (아이디 입력)
  Widget _buildFindPasswordTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _pwEmailController,
            onChanged: (value) {
              _pwEmailController.text = _validatePwInput(value);
              _pwEmailController.selection = TextSelection.fromPosition(
                TextPosition(offset: _pwEmailController.text.length),
              );
            },
            decoration: InputDecoration(
              hintText: "가입된 아이디",
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              print("비밀번호 찾기 버튼 눌림");
              final id = _pwEmailController.text.trim();
              if (id.isEmpty) {
                _showMessage("아이디를 입력해주세요.");
                return;
              }
              try {
                // find_account_service.dart에 정의된 AccountService 사용
                await findAccount.AccountService.sendPasswordResetEmailById(id: id);
                if (mounted) {
                  _showMessage("비밀번호 재설정 이메일을 전송하였습니다. 이메일을 확인해주세요.");
                }
                print("비밀번호 재설정 이메일 전송 성공");
              } catch (e) {
                if (mounted) {
                  _showMessage(e.toString());
                }
                print("비밀번호 재설정 이메일 전송 실패: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("비밀번호 재설정", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// 메시지 표시용 다이얼로그
  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              print("다이얼로그 닫기 버튼 클릭");
              Navigator.pop(context);
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }
}
