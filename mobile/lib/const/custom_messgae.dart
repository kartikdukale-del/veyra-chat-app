import 'package:app/const/custom_color.dart';
import 'package:app/model/message_model.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  const MessageBubble({super.key, required this.message,this.onDelete,this.onEdit});

  @override
  Widget build(BuildContext context) {
    return  Align(
  alignment: message.isMe
      ? Alignment.centerRight
      : Alignment.centerLeft,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: message.isMe
        ? MainAxisAlignment.end
        : MainAxisAlignment.start,
    children: [ 
      if (message.isMe)
        PopupMenuButton<String>(
          color: AppColor.white ,
          icon: const Icon(Icons.more_horiz, size: 18),
          onSelected: (value) {
            if (value == 'edit') {
          onEdit?.call();
            } else if (value == 'delete') {
            onDelete?.call();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: message.isMe
              ? const Color(0xFFEAF1FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.isMe ? '10:36 AM · Read' : '10:34 AM',
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
  }
}
