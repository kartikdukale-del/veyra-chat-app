import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_messgae.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/model/message_model.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String userName;
  const MessageScreen({super.key, required this.userName});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController messagecontroller = TextEditingController();
  final List<Message> messages = [
    Message(text: "Hey! Are we still on for coffee later?", isMe: false),
    Message(text: "Absolutely. How does 4:30 sound?", isMe: true),
    Message(text: "That sounds perfect. See you then!", isMe: false),
  ];
  @override
  void dispose() {
    messagecontroller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightgrey,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(child: Icon(Icons.person)),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontWeight: AppFontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  AppString.online,
                  style: TextStyle(color: AppColor.blue, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz))],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  AppString.today,
                  style: TextStyle(color: AppColor.grey, fontSize: 10),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      return MessageBubble(
                        message: message,
                        onDelete: () {
                          setState(() {
                            messages.removeAt(index);
                          });
                        },
                        onEdit: () {
                          final controller = TextEditingController(
                            text: message.text,
                          );

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: AppColor.white,
                                content: TextField(controller: controller),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final updateText = controller.text.trim();

                                      if (updateText.isNotEmpty) {
                                        setState(() {
                                          message.text = updateText;
                                        });
                                        Navigator.pop(context);
                                        controller.dispose();
                                      }
                                    },
                                    child: Text("Save"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: AppColor.white,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messagecontroller,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),

                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final text = messagecontroller.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      messages.add(Message(text: text, isMe: true));
                    });
                    messagecontroller.clear();
                  },
                  icon: Icon(Icons.send_rounded, color: AppColor.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
