import 'package:flutter/material.dart';

class FindAccount extends StatefulWidget {
  const FindAccount({super.key});

  @override
  State<FindAccount> createState() => _FindAccountState();
}

class _FindAccountState extends State<FindAccount> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _idEmailController = TextEditingController(); // 아이디 찾기 입력창
  final TextEditingController _pwEmailController = TextEditingController(); // 비밀번호 찾기 입력창
  int _selectedTabIndex = 0; // 현재 선택된 탭 인덱스 (0: 아이디 찾기, 1: 비밀번호 찾기)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 탭 변경 감지하여 입력값 초기화 & AppBar 제목 변경
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
        _clearInputFields(); // ✅ 탭이 변경될 때 입력값 초기화
      });
    });
  }

  /// 탭 변경 시 입력값 초기화
  void _clearInputFields() {
    if (_selectedTabIndex == 0) {
      _pwEmailController.clear(); // 비밀번호 찾기 입력 필드 초기화
    } else {
      _idEmailController.clear(); // 아이디 찾기 입력 필드 초기화
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
    final RegExp regex = RegExp(r'^[a-zA-Z0-9@.]*$'); // ✅ 영어 대소문자만 허용
    if (!regex.hasMatch(value)) {
      return value.replaceAll(RegExp(r'[^a-zA-Z0-9@.]'), ''); // ❌ 허용되지 않은 문자 제거
    }
    return value;
  }

  /// 비밀번호 찾기 - 입력값 필터 (영어, 숫자, @, . 허용)
  String _validatePwInput(String value) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]*$'); // ✅ 영어, 숫자, @, . 허용
    if (!regex.hasMatch(value)) {
      return value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''); // ❌ 허용되지 않은 문자 제거
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedTabIndex == 0 ? "아이디 찾기" : "비밀번호 찾기", // ✅ 탭에 따라 AppBar 제목 변경
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 탭바 (아이디 찾기 / 비밀번호 찾기)
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "아이디 찾기"),
              Tab(text: "비밀번호 찾기"),
            ],
          ),

          // 탭 전환되는 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFindIdTab(), // 아이디 찾기 화면
                _buildFindPasswordTab(), // 비밀번호 찾기 화면
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "아이디 찾기" 탭 화면 (영어만 입력 가능)
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
            onPressed: () {}, // 아이디 찾기 기능 추가 필요
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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

  /// "비밀번호 찾기" 탭 화면 (영어, 숫자, @, . 만 입력 가능)
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
            onPressed: () {}, // 비밀번호 찾기 기능 추가 필요
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
}
