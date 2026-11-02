import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_messgae.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/model/message_model.dart';
import 'package:app/repo/auth_repo.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String userName;
  final int conversationId;
  const MessageScreen({super.key, required this.userName,required this.conversationId});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final   AuthRepo authRepo =AuthRepo();
  final TextEditingController messagecontroller = TextEditingController();
 List<Message> messages = [];
 bool isLoading = true;

Future <void > loadMessages() async{
  try {
    final currentUser  =await authRepo.getCurrent();

    final response = await authRepo.getMessages(
      widget.conversationId,
    );

    final loadMessages = response.map((item) {
      return Message.fromJson(
        Map<String,dynamic>.from(item),
        
         currentUser.id,
         );
    }).toList();

    if (!mounted) return;

    setState(() {
      messages = loadMessages;
      isLoading = false;
    });
    
  } catch (e) {
    debugPrint("Load messages error : $e");

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }
}
  Future<void> handleSendMessage() async{
    final content = messagecontroller.text.trim();


    if(content.isEmpty)   return;
     final newMessage =Message(
      text:content,
      isMe: true,
     );

    setState(() {
      messages.add(newMessage);
    });
    messagecontroller.clear();
    try {
      await  authRepo.sendMessage(
        widget.conversationId,
        content,
      );
      await loadMessages();

    }catch(e){
      debugPrint("Send message error: $e");
      if (!mounted) return;

      setState(() {
        messages.remove(newMessage);
      });
    }
  }
  @override
  void initState(){
    super.initState();
    loadMessages();
  }
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
                   final currentMessage = messages[index];

                      return MessageBubble(
                        message: currentMessage,
                        onDelete: () {
                          setState(() {
                            messages.removeAt(index);
                          });
                        },
                        onEdit: () {
                          final controller = TextEditingController(
                            text: currentMessage.text,
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
                                          currentMessage.text = updateText;
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
                  onPressed:handleSendMessage,
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
