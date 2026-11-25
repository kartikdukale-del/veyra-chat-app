class Message {
  final int? id;
  final int? conversationId;
  final int? senderId;
  String text;
  final bool isMe;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? clientMsgId;
  final bool isPending;

  Message({
    this.id,
    this.conversationId,
    this.senderId,
    required this.text,
    required this.isMe,
    this.createdAt,
    this.updatedAt,
    this.clientMsgId,
    this.isPending = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    final senderId = json['sender_id'] as int?;
    return Message(
      id: json['id'] as int?,
      conversationId: json['conversation_id'] as int?,
      senderId: senderId,
      text: (json['content'] ?? '').toString(),
      isMe: senderId == currentUserId,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
      isPending: false,
    );
  }
}
