import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_input.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/repo/auth_repo.dart';
import 'package:app/utiles/routing_bottomNavigation.dart';
import 'package:app/view/create_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepo authrepo = AuthRepo();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
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
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                final result = await authrepo.login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                );
                                final token = result['access_token'];
                                if (token == null || token.toString().isEmpty) {
                                  throw Exception('Access token not received');
                                }
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RoutingBottomnavigation(),
                                  ),
                                );
                              } on DioException catch (e) {
                                if (!context.mounted) return;
                                final detail = e.response?.data is Map
                                    ? e.response?.data['detail']
                                    : null;
                                final message = detail?.toString() ??
                                    (e.type == DioExceptionType.connectionTimeout ||
                                     e.type == DioExceptionType.receiveTimeout
                                        ? "Server connection timed out. Server waking up, please try again."
                                        : (e.message ?? "Login failed"));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Login failed: $e")),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        minimumSize: Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColor.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
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
