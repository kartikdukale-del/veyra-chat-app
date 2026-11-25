import 'package:app/repo/auth_repo.dart';
import 'package:app/view/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const VeryaApp());
}

class VeryaApp extends StatelessWidget {
  const VeryaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AuthRepo().navigatorKey,
      title: "Verya Chat App",
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
