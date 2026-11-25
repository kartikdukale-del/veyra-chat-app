import 'package:app/model/usser_model.dart';

class ConversationModel {
  final int conversationId;
  final UserModel otherUser;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int? lastMessageSenderId;

  ConversationModel({
    required this.conversationId,
    required this.otherUser,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversation_id'],
      otherUser: UserModel.fromJson(
        Map<String, dynamic>.from(json['other_user']),
      ),
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      lastMessageSenderId: json['last_message_sender_id'] as int?,
    );
  }
}
