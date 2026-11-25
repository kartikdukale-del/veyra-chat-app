import 'package:app/const/custom_color.dart';
import 'package:app/model/message_model.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  const MessageBubble({
    super.key,
    required this.message,
    this.onDelete,
    this.onEdit,
  });

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  String _buildStatusText() {
    if (message.isPending) {
      return 'Sending...';
    }
    final timeStr = _formatTime(message.createdAt);
    final editedSuffix = message.updatedAt != null ? ' · Edited' : '';
    if (timeStr.isEmpty) {
      return message.isMe ? 'Sent$editedSuffix' : editedSuffix.trim();
    }
    return message.isMe
        ? '$timeStr · Sent$editedSuffix'
        : '$timeStr$editedSuffix';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (message.isMe && !message.isPending && message.id != null)
            PopupMenuButton<String>(
              color: AppColor.white,
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
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: message.isMe ? const Color(0xFFEAF1FF) : Colors.white,
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
                    _buildStatusText(),
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
