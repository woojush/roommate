import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'config/firebase_options.dart';
import 'package:findmate1/ui/account/login_screen.dart';
import 'package:findmate1/ui/screens/main_screen.dart';
import 'theme.dart';
import 'package:findmate1/service/tabs/matching/checklist/checklist_provider.dart';
import 'style/font.dart';
import 'package:provider/provider.dart';

/// 전역적으로 사용할 RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// 전역 navigatorKey 선언
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ChecklistProvider>(
          create: (_) => ChecklistProvider(),
        ),
        // 필요한 다른 Provider 추가
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<firebase_auth.User?> _getUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return firebase_auth.FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindMate',
      navigatorKey: navigatorKey, // 전역 navigatorKey 할당
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: MyFontFamily.oagothicExtraBold),
          bodyMedium: TextStyle(fontFamily: MyFontFamily.oagothicExtraBold),
          displayLarge: TextStyle(fontFamily: MyFontFamily.oagothicExtraBold),
          displayMedium: TextStyle(fontFamily: MyFontFamily.oagothicExtraBold),
          headlineLarge: TextStyle(fontFamily: MyFontFamily.oagothicExtraBold),
          headlineMedium: TextStyle(fontFamily: MyFontFamily.oagothicExtraBold),
          titleLarge: TextStyle(fontFamily: MyFontFamily.oagothicMedium),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      navigatorObservers: [routeObserver],
      // 라우트를 명시적으로 정의합니다.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        // 필요에 따라 다른 라우트 추가
      },
      // home 대신 initialRoute를 설정할 수도 있습니다.
      home: FutureBuilder<firebase_auth.User?>(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return const MainScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
