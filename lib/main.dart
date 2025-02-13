import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/firebase_options.dart';
import 'screens/login/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<User?> _getUser() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Firebase 안정성 확보
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<User?>(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()), // 로딩 화면
            );
          } else if (snapshot.hasData) {
            return const MainScreen(); // ✅ 로그인 O -> 메인 화면
          } else {
            return const LoginScreen(); // ✅ 로그인 X -> 로그인 화면
          }
        },
      ),
    );
  }
}
