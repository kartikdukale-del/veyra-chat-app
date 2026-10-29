import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/view/login_screen.dart';
import 'package:flutter/material.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();

    Future.delayed(Duration(seconds: 3),(){
      if (!mounted) return;
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) =>LoginScreen()));
          });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                child: Column(
                  children: [
                    Image.asset("assets/icon/logo.png", height: 80, width: 80),
                    Text(AppString.verya, style: TextStyle(fontSize: 30)),
                    Text(
                      AppString.closer,
                      style: TextStyle(color: AppColor.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Column(
                  children: [
                    SizedBox(
                      height: 22,
                      width: 22,
                      child:CircularProgressIndicator(color: AppColor.blue),
                    ),
                    SizedBox(height: 6),
                    Text(
                      AppString.simple,
                      style: TextStyle(color: AppColor.grey, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}