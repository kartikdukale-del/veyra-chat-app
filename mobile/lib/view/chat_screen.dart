import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/utiles/routing_bottomNavigation.dart';
import 'package:app/view/message_screen.dart';

import 'package:flutter/material.dart';

List<String> users = [
  "Maya Chen",
  "Noah Williams",
  "Amelia Hart",
  "Sofia Miller",
  "Ethan Brooks",
];

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
                      children: [
                        Text(
                          AppString.good,
                          style: TextStyle(color: AppColor.grey, fontSize: 10),
                        ),
                        SizedBox(height: 5),
                        Text(AppString.verya, style: TextStyle(fontSize: 25)),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.buttonBack,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RoutingBottomnavigation(initialIndex: 1),
                          ),
                        );
                      },
                      icon: Icon(Icons.search, color: AppColor.blue),
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
                    Text(
                      AppString.message,
                      style: TextStyle(fontWeight: AppFontWeight.w500),
                    ),
                    Spacer(),
                    Text(
                      AppString.conversations,
                      style: TextStyle(color: AppColor.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MessageScreen(userName: users[index]),
                              ),
                            );
                          },
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(
                            users[index],
                            style: TextStyle(fontWeight: AppFontWeight.w700),
                          ),
                          subtitle: Text(
                            "Last message here",
                            style: TextStyle(
                              color: AppColor.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColor.grey,
                        ),
                      ],
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
