import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // 이 덕분에 firebase_auth.으로 패키지 내의 다양한 기능을 사용할 수 있다.
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'package:findmate1/ui/account/login_screen.dart'; // 로그인 창
import 'package:findmate1/ui/screens/main_screen.dart'; // 로그인 이후 나올 메인 스크린
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main()함수 내에서 async/await를 실행하기 전에 반드시 호출해야 하는 코드
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Firebase를 앱에서 사용할 수 있도록 초기화하는 코드. (Firebase 기능 사용하려면 사용 전 초기화 필수)
  runApp(const MyApp()); // Myapp 클래스 실행.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<firebase_auth.User?> _getUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Firebase가 완전히 로드되도록 짧은 딜레이(0.5초)를 주는 역할.
    return firebase_auth.FirebaseAuth.instance.currentUser;
    // 현재 로그인한 사용자가 있으면 User 객체를 반환, 로그아웃된 상태면 null을 반환
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindMate',
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.backgroundColor,
      ),
      // 앱의 기본 색상 계열을 검은색으로 지정.
      home: FutureBuilder<firebase_auth.User?>(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { // 연결 상태 기다리는 중이면
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()), // 로딩중 아이콘 띄우고
            );
          } else if (snapshot.hasData) { // 데이터 있으면 (로그인 됐으면)
            return const MainScreen(); // MainScreen() 실행
          } else {
            return const LoginScreen(); // 싹 다 아니면(로딩중 아닌데 로그인 아닌경우) -> 로그인 안되어있으면 로그인 창 띄우기
          }
        },
      ),
    );
  }
}
