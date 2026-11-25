import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/model/conversation_model.dart';
import 'package:app/repo/auth_repo.dart';
import 'package:app/utiles/routing_bottomNavigation.dart';
import 'package:app/view/message_screen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthRepo authRepo = AuthRepo();

  late Future<List<ConversationModel>> conversationsFuture;

  @override
  void initState() {
    super.initState();
    conversationsFuture = authRepo.getConversations();
  }

  Future<void> _refreshConversations() async {
    setState(() {
      conversationsFuture = authRepo.getConversations();
    });
    await conversationsFuture;
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
                child: FutureBuilder<List<ConversationModel>>(
                  future: conversationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: TextButton(
                          onPressed: _refreshConversations,
                          child: Text("Unable to load conversations. Tap to retry"),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No conversations yet"));
                    }

                    final conversations = snapshot.data!;

                    return RefreshIndicator(
                      onRefresh: _refreshConversations,
                      child: ListView.builder(
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          final preview =
                              (conv.lastMessage != null &&
                                  conv.lastMessage!.isNotEmpty)
                              ? conv.lastMessage!
                              : "Start a conversation";
                          return Column(
                            children: [
                              ListTile(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessageScreen(
                                        userName: conv.otherUser.fullName,
                                        conversationId: conv.conversationId,
                                      ),
                                    ),
                                  );
                                  if (mounted) {
                                    _refreshConversations();
                                  }
                                },
                                leading: CircleAvatar(child: Icon(Icons.person)),
                                title: Text(
                                  conv.otherUser.fullName,
                                  style: TextStyle(
                                    fontWeight: AppFontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  preview,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
