import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_input.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/model/usser_model.dart';
import 'package:app/repo/auth_repo.dart';
import 'package:app/view/message_screen.dart';
import 'package:flutter/material.dart';



class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AuthRepo authRepo = AuthRepo();
  late final TextEditingController searchController;
  late final FocusNode searchFocus;
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchFocus = FocusNode();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }
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
                        Text(AppString.find, style: TextStyle(fontSize: 25)),

                        SizedBox(height: 5),
                        Text(
                          AppString.search,
                          style: TextStyle(color: AppColor.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Divider(height: 1),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        autofocus: true,
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {});
                        },

                        hintText: "Search usres",
                        prefixicon: Icons.search_rounded,
                        prefixIconColor: AppColor.blue,
                        obscureText: false,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Text(
                  AppString.suggested,
                  style: TextStyle(fontWeight: AppFontWeight.w500),
                ),
              ),
              SizedBox(height: 15),
              Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<UserModel>>(
                  future: authRepo.getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("unable to load users"));
                    }
                    final allUsers = snapshot.data ?? [];

                    final filteredUsers = allUsers.where((users) {
                      return users.fullName.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      );
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return Center(child: Text("No users found"));
                    }

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];

                        return ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(user.fullName),
                          trailing: TextButton(
                            onPressed: () async {
                              try {
                                final conversationId = await authRepo
                                    .createConversation(user.id);

                                if (!mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageScreen(
                                      userName: user.fullName,
                                      conversationId: conversationId,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                debugPrint("Conversation error: $e");
                              }
                            },
                            child: Text("Message"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
