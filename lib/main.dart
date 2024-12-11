import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projek_akhir/login_page.dart';
import 'package:provider/provider.dart';
import 'package:projek_akhir/task_provider.dart';
import 'package:projek_akhir/authentication_provider.dart';
import 'package:projek_akhir/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MaterialApp(
          title: 'Task Management',
          theme: ThemeData(),
          home: const HomePage(),
          initialRoute:
              FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
          routes: {
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomePage(),
          }),
    );
  }
}
