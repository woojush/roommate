import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'package:findmate1/ui/account/login_screen.dart';
import 'package:findmate1/ui/screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://your-project-ref.supabase.co', // Replace with your Supabase project URL
    anonKey: 'your-anon-key', // Replace with your Supabase anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<firebase_auth.User?> _getUser() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Ensures Firebase is ready
    return firebase_auth.FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<firebase_auth.User?>(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return const MainScreen(); // Logged in -> Main Screen
          } else {
            return const LoginScreen(); // Not logged in -> Login Screen
          }
        },
      ),
    );
  }
}
