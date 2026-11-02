class Message {
  String text;
  final bool isMe;
   Message({
     required this.text,
    required this.isMe,
  });
  factory Message.fromJson(
    Map<String,dynamic> json,
    int currentUserId,
  ) {
    return Message(text:  json['content'], isMe: json['sender_id'] == currentUserId,);
  }
}