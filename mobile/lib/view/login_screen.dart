import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_input.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/utiles/routing_bottomNavigation.dart';

import 'package:app/view/create_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset("assets/icon/logo.png"),
                  SizedBox(width: 10),
                  Text(
                    AppString.verya,
                    style: TextStyle(
                      fontWeight: AppFontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 36),
              Text(AppString.welcome, style: TextStyle(fontSize: 30)),
              SizedBox(height: 6),
              Text(
                AppString.signin,
                style: TextStyle(color: AppColor.grey, fontSize: 13),
              ),
              SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppString.email,
                      style: TextStyle(
                        fontWeight: AppFontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 8),
                    CustomInput(
                      controller: emailController,
                      
                      prefixicon: Icons.mail_outline_rounded,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is Required";
                        }
                        if (!value.contains("@") || !value.contains(".")) {
                          return "Enter a Valid Email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    Text(
                      AppString.password,
                      style: TextStyle(
                        fontWeight: AppFontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 8),
                    CustomInput(
                    
                      controller: passwordController,
                      hintText: "Enter your password",
                      prefixicon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be atleast 6 characters";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    Align(
                      alignment: AlignmentGeometry.centerRight,
                      child: Text(
                        AppString.forgot,
                        style: TextStyle(
                          color: AppColor.blue,
                          fontSize: 13,
                          fontWeight: AppFontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoutingBottomnavigation(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        minimumSize: Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                      child: Text(
                        AppString.log,
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 16,
                          fontWeight: AppFontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppString.newto,
                    style: TextStyle(
                      color: AppColor.hintcolor,
                      fontWeight: AppFontWeight.w400,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateScreen()),
                      );
                    },
                    child: Text(
                      AppString.create,
                      style: TextStyle(
                        color: AppColor.blue,
                        fontWeight: AppFontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
