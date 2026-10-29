import 'package:app/view/splash_screen.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(VeryaApp());
}
class VeryaApp extends StatelessWidget {
  const VeryaApp({super.key});
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Verya Chat App",
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}