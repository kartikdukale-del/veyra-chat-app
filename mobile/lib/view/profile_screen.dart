import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/model/usser_model.dart';
import 'package:app/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepo _authRepo = AuthRepo();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final aboutController = TextEditingController();
  late Future<UserModel> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = loadUser();
  }

  Future<UserModel> loadUser() async {
    final user = await _authRepo.getCurrent(forceRefresh: true);
    nameController.text = user.fullName;
    emailController.text = user.email;
    aboutController.text = user.about;
    return user;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  void showEditDialog() {
    final editName = TextEditingController(text: nameController.text);
    final editEmail = TextEditingController(text: emailController.text);
    final editAbout = TextEditingController(text: aboutController.text);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColor.white,
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editName,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: editEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: editAbout,
                  decoration: const InputDecoration(
                    labelText: 'About',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = editName.text.trim();
                final newEmail = editEmail.text.trim();
                final newAbout = editAbout.text.trim();
                Navigator.pop(dialogContext);

                try {
                  final updated = await _authRepo.updateProfile(
                    fullName: newName,
                    email: newEmail,
                    about: newAbout,
                  );
                  if (!mounted) return;
                  setState(() {
                    nameController.text = updated.fullName;
                    emailController.text = updated.email;
                    aboutController.text = updated.about;
                    userFuture = Future.value(updated);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                } on DioException catch (e) {
                  if (!mounted) return;
                  final detail = e.response?.data is Map
                      ? e.response?.data['detail']
                      : null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        detail?.toString() ?? 'Failed to update profile',
                      ),
                    ),
                  );
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update profile')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      editName.dispose();
      editEmail.dispose();
      editAbout.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: FutureBuilder<UserModel>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Unable to load profile"),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text("No user Data found"),
            );
          }
          final user = snapshot.data!;

          return SafeArea(
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
                              AppString.profile,
                              style: TextStyle(fontSize: 25),
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      spacing: 15,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(radius: 40, child: Icon(Icons.person)),
                          ],
                        ),
                        Text(user.fullName, style: TextStyle(fontSize: 23)),
                        Text(
                          user.email,
                          style: TextStyle(color: AppColor.grey, fontSize: 10),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.blue,
                            side: BorderSide(color: AppColor.blue, width: 1.5),
                            minimumSize: Size(120, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          onPressed: showEditDialog,
                          child: Text(
                            AppString.edit,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: AppFontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 23),
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
                              child: Icon(
                                Icons.person,
                                color: AppColor.blue,
                              ),
                            ),
                            SizedBox(width: 13),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppString.name,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColor.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user.fullName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: AppFontWeight.w500,
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
                                Icons.email_outlined,
                                color: AppColor.blue,
                              ),
                            ),
                            SizedBox(width: 13),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppString.email,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColor.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: AppFontWeight.w500,
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
                                Icons.chat_bubble_outline_outlined,
                                color: AppColor.blue,
                              ),
                            ),
                            SizedBox(width: 13),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppString.about,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColor.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user.about,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: AppFontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Divider(height: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
