import 'dart:async';
import 'dart:convert';
import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';
import 'package:app/const/custom_messgae.dart';
import 'package:app/const/custom_string.dart';
import 'package:app/model/message_model.dart';
import 'package:app/repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageScreen extends StatefulWidget {
  final String userName;
  final int conversationId;
  const MessageScreen({
    super.key,
    required this.userName,
    required this.conversationId,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final AuthRepo authRepo = AuthRepo();
  final TextEditingController messagecontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [];
  bool isLoading = true;
  int? _currentUserId;

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Timer? _fallbackSyncTimer;

  bool _isConnected = false;
  bool _isDisposed = false;
  bool _isSyncing = false;
  int _reconnectAttempts = 0;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await loadMessages();
    if (!_isDisposed) {
      await _connectWebSocket();
      _startFallbackSyncTimer();
    }
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (jump) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  int? get _lastServerMessageId {
    int? maxId;
    for (final msg in messages) {
      if (msg.id != null && (maxId == null || msg.id! > maxId)) {
        maxId = msg.id;
      }
    }
    return maxId;
  }

  Future<void> loadMessages() async {
    try {
      final currentUser = await authRepo.getCurrent();
      _currentUserId = currentUser.id;

      final response = await authRepo.getMessages(widget.conversationId);
      final loaded = response
          .map(
            (item) => Message.fromJson(
              Map<String, dynamic>.from(item),
              currentUser.id,
            ),
          )
          .toList();

      if (!mounted || _isDisposed) return;

      setState(() {
        messages = loaded;
        isLoading = false;
      });
      _scrollToBottom(jump: true);
    } catch (e) {
      debugPrint("Load messages error : $e");
      if (!mounted || _isDisposed) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _syncMissedMessages() async {
    if (_isDisposed || _isSyncing || _currentUserId == null) return;
    _isSyncing = true;
    try {
      final response = await authRepo.getMessages(
        widget.conversationId,
        afterId: _lastServerMessageId,
      );
      if (_isDisposed || !mounted || response.isEmpty) return;

      bool added = false;
      setState(() {
        for (final item in response) {
          final incoming = Message.fromJson(
            Map<String, dynamic>.from(item),
            _currentUserId!,
          );
          if (incoming.id != null &&
              !messages.any((m) => m.id == incoming.id)) {
            messages.add(incoming);
            added = true;
          }
        }
      });
      if (added) {
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Sync missed messages error: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _connectWebSocket() async {
    if (_isDisposed) return;
    _cleanupWebSocket();

    final token = await authRepo.getToken();
    if (token == null || token.isEmpty || _isDisposed) return;

    final wsUrl =
        "${authRepo.wsBaseUrl}/ws/conversations/${widget.conversationId}?token=${Uri.encodeQueryComponent(token)}";

    try {
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel = channel;

      await channel.ready;
      if (_isDisposed) {
        channel.sink.close();
        return;
      }

      setState(() {
        _isConnected = true;
        _reconnectAttempts = 0;
      });

      // Sync any messages missed while disconnected
      await _syncMissedMessages();

      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
        if (_isConnected && _channel != null) {
          try {
            _channel!.sink.add(jsonEncode({"type": "ping"}));
          } catch (_) {}
        }
      });

      _wsSubscription = channel.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          debugPrint("WebSocket error: $error");
          _handleDisconnect();
        },
        onDone: () {
          debugPrint("WebSocket closed");
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("WebSocket connect error: $e");
      _handleDisconnect();
    }
  }

  void _handleWebSocketMessage(dynamic raw) {
    if (_isDisposed || !mounted || _currentUserId == null) return;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw.toString()));
      final eventType = data['type'];

      if (eventType == 'new_message' && data['message'] != null) {
        final incoming = Message.fromJson(
          Map<String, dynamic>.from(data['message']),
          _currentUserId!,
        );
        final clientMsgId = data['client_msg_id'] as String?;

        setState(() {
          if (clientMsgId != null) {
            final pendingIdx = messages.indexWhere(
              (m) => m.clientMsgId == clientMsgId,
            );
            if (pendingIdx != -1) {
              messages[pendingIdx] = incoming;
              return;
            }
          }
          if (incoming.id != null &&
              messages.any((m) => m.id == incoming.id)) {
            return;
          }
          messages.add(incoming);
        });
        _scrollToBottom();
      } else if (eventType == 'message_updated' && data['message'] != null) {
        final updated = Message.fromJson(
          Map<String, dynamic>.from(data['message']),
          _currentUserId!,
        );
        setState(() {
          final idx = messages.indexWhere((m) => m.id == updated.id);
          if (idx != -1) {
            messages[idx] = updated;
          }
        });
      } else if (eventType == 'message_deleted') {
        final deletedId = data['message_id'] as int?;
        if (deletedId != null) {
          setState(() {
            messages.removeWhere((m) => m.id == deletedId);
          });
        }
      }
    } catch (e) {
      debugPrint("WebSocket parse error: $e");
    }
  }

  void _handleDisconnect() {
    if (_isDisposed) return;
    _cleanupWebSocket();
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
    }
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    final delaySeconds = (_reconnectAttempts * 2).clamp(2, 15);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed && !_isConnected) {
        _connectWebSocket();
      }
    });
  }

  void _startFallbackSyncTimer() {
    _fallbackSyncTimer?.cancel();
    _fallbackSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isDisposed && !_isConnected) {
        _syncMissedMessages();
      }
    });
  }

  void _cleanupWebSocket() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _wsSubscription?.cancel();
    _wsSubscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  Future<void> handleSendMessage() async {
    final content = messagecontroller.text.trim();
    if (content.isEmpty) return;

    final uid = _currentUserId ?? (await authRepo.getCurrent()).id;
    _currentUserId = uid;

    final clientMsgId = '${DateTime.now().microsecondsSinceEpoch}_$uid';
    final optimistic = Message(
      text: content,
      isMe: true,
      senderId: uid,
      conversationId: widget.conversationId,
      createdAt: DateTime.now(),
      clientMsgId: clientMsgId,
      isPending: true,
    );

    setState(() {
      messages.add(optimistic);
    });
    messagecontroller.clear();
    _scrollToBottom();

    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(
          jsonEncode({
            "type": "send_message",
            "content": content,
            "client_msg_id": clientMsgId,
          }),
        );
        return;
      } catch (e) {
        debugPrint("WS send failed, falling back to REST: $e");
      }
    }

    // Fallback to REST POST if WebSocket is unavailable
    try {
      final savedJson = await authRepo.sendMessage(
        widget.conversationId,
        content,
        clientMsgId: clientMsgId,
      );
      if (!mounted || _isDisposed) return;
      final confirmed = Message.fromJson(savedJson, uid);
      setState(() {
        final idx = messages.indexWhere((m) => m.clientMsgId == clientMsgId);
        if (idx != -1) {
          messages[idx] = confirmed;
        } else if (!messages.any((m) => m.id == confirmed.id)) {
          messages.add(confirmed);
        }
      });
    } catch (e) {
      debugPrint("Send message error: $e");
      if (!mounted || _isDisposed) return;
      setState(() {
        messages.removeWhere((m) => m.clientMsgId == clientMsgId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message")),
      );
    }
  }

  Future<void> _handleEditMessage(Message currentMessage, String newText) async {
    if (currentMessage.id == null) return;
    try {
      final updatedJson = await authRepo.editMessage(
        widget.conversationId,
        currentMessage.id!,
        newText,
      );
      if (!mounted || _isDisposed || _currentUserId == null) return;
      final updated = Message.fromJson(updatedJson, _currentUserId!);
      setState(() {
        final idx = messages.indexWhere((m) => m.id == updated.id);
        if (idx != -1) {
          messages[idx] = updated;
        }
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to edit message")),
      );
    }
  }

  Future<void> _handleDeleteMessage(Message currentMessage) async {
    if (currentMessage.id == null) return;
    try {
      await authRepo.deleteMessage(widget.conversationId, currentMessage.id!);
      if (!mounted || _isDisposed) return;
      setState(() {
        messages.removeWhere((m) => m.id == currentMessage.id);
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete message")),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _fallbackSyncTimer?.cancel();
    _cleanupWebSocket();
    _scrollController.dispose();
    messagecontroller.dispose();
    super.dispose();
  }

  @override
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
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final currentMessage = messages[index];

                            return MessageBubble(
                              message: currentMessage,
                              onDelete: () =>
                                  _handleDeleteMessage(currentMessage),
                              onEdit: () {
                                final controller = TextEditingController(
                                  text: currentMessage.text,
                                );

                                showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      backgroundColor: AppColor.white,
                                      content: TextField(controller: controller),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final updateText =
                                                controller.text.trim();
                                            if (updateText.isNotEmpty) {
                                              Navigator.pop(dialogContext);
                                              _handleEditMessage(
                                                currentMessage,
                                                updateText,
                                              );
                                            }
                                          },
                                          child: Text("Save"),
                                        ),
                                      ],
                                    );
                                  },
                                ).then((_) => controller.dispose());
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
                    onFieldSubmitted: (_) => handleSendMessage(),
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
                  onPressed: handleSendMessage,
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
