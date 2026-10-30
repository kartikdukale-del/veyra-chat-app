import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_input.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/repo/auth_repo.dart';
import 'package:app/utiles/routing_bottomNavigation.dart';
import 'package:app/view/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthRepo authRepo = AuthRepo();
  bool isLoading = false;
  
  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final response = await authRepo.signup(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Account created successfully")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (contex) => LoginScreen()),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data['detail'] ?? "Signup failed";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.toString())));
    } finally {
      if(mounted) {
        setState(() {
          isLoading =false;
        });
      }
    }
  }
  @override

  void dispose() {
    nameController.dispose();
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
              Text(AppString.createacc, style: TextStyle(fontSize: 30)),
              SizedBox(height: 6),
              Text(
                AppString.join,
                style: TextStyle(color: AppColor.grey, fontSize: 13),
              ),
              SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppString.full,
                      style: TextStyle(
                        fontWeight: AppFontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 8),
                    CustomInput(
                      controller: nameController,

                      prefixicon: Icons.account_circle_outlined,
                      obscureText: false,
                      hintText: "Your name",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Full name is required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    Text(
                      AppString.emailAdd,
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
                          return "Email is required";
                        }
                        if (!value.contains('@') || !value.contains(".")) {
                          return "Enter a valid email";
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

                      hintText: "Create a password",
                      prefixicon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is requird";
                        }
                        if (value.length < 6) {
                          return "Password must at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 6),
                    Text(
                      AppString.use,
                      style: TextStyle(color: AppColor.grey, fontSize: 10),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null: signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        minimumSize: Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                      child: isLoading?CircularProgressIndicator(
                        color: AppColor.white
                      )
                      :Text(
                        AppString.create,
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppString.already,
                    style: TextStyle(
                      color: AppColor.hintcolor,
                      fontWeight: AppFontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      AppString.log,
                      style: TextStyle(
                        color: AppColor.blue,
                        fontSize: 13,
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
