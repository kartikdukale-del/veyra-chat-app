import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/view/login_screen.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppString.settings,
                          style: TextStyle(fontSize: 25),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 23,
                  vertical: 15,
                ),
                child: Column(
                  children: [
                    Divider(height: 1),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColor.buttonBack,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.person, color: AppColor.blue),
                        ),
                        SizedBox(width: 13),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.account,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: AppFontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppString.personal,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(height: 1),

                    SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColor.buttonBack,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: AppColor.blue,
                          ),
                        ),
                        SizedBox(width: 13),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.notifications,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: AppFontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppString.sound,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(height: 1),

                    SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColor.buttonBack,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.lock_outlined,
                            color: AppColor.blue,
                          ),
                        ),
                        SizedBox(width: 13),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.privacy,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: AppFontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppString.blocked,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(height: 1),

                    SizedBox(height: 15),
                    Divider(height: 1),

                    SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColor.buttonBack,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.help_outline_outlined,
                            color: AppColor.blue,
                          ),
                        ),
                        SizedBox(width: 13),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.help,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: AppFontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppString.support,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(height: 1),
                    SizedBox(height: 20),

                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 55),
                        foregroundColor: AppColor.red,
                        backgroundColor: AppColor.logoutback,
                        side: BorderSide(color: AppColor.logoutside),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 16, weight: 600),
                          SizedBox(width: 8),
                          Text(
                            AppString.logout,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: AppFontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: AlignmentGeometry.bottomCenter,
                      child: Text(
                        AppString.version,
                        style: TextStyle(fontSize: 9, color: AppColor.grey),
                        ),
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
