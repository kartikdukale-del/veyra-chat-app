import 'package:app/model/conversation_model.dart';
import 'package:app/model/usser_model.dart';
import 'package:app/view/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepo {
  static final AuthRepo _instance = AuthRepo._internal();
  factory AuthRepo() => _instance;

  static const String apiBaseUrl = "https://veyra-chat-app.onrender.com";

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late final Dio dio;
  UserModel? _cachedUser;
  bool _isRedirectingToLogin = false;

  String get wsBaseUrl {
    if (apiBaseUrl.startsWith("https://")) {
      return apiBaseUrl.replaceFirst("https://", "wss://");
    }
    return apiBaseUrl.replaceFirst("http://", "ws://");
  }

  AuthRepo._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        headers: {"Content-Type": "application/json"},
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await storage.read(key: "access_token");
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
          onError: (error, handler) async {
            final path = error.requestOptions.path;
            final isAuthEndpoint =
                path.contains('/users/login') || path.contains('/users/signup');
            if (error.response?.statusCode == 401 && !isAuthEndpoint) {
              await storage.delete(key: "access_token");
              _cachedUser = null;
              if (!_isRedirectingToLogin && navigatorKey.currentState != null) {
                _isRedirectingToLogin = true;
                navigatorKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                Future.delayed(const Duration(seconds: 1), () {
                  _isRedirectingToLogin = false;
                });
              }
            }
            handler.next(error);
          },
        ),
      );
  }

  Future<String?> getToken() async {
    return storage.read(key: "access_token");
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      "/users/login",
      data: {'email': email, 'password': password},
    );
    final token = response.data['access_token'];
    await storage.write(key: 'access_token', value: token);
    _cachedUser = null;
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      "/users/signup",
      data: {"full_name": fullName, "email": email, "password": password},
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<UserModel> getCurrent({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedUser != null) {
      return _cachedUser!;
    }
    final response = await dio.get("/users/me");
    _cachedUser = UserModel.fromJson(Map<String, dynamic>.from(response.data));
    return _cachedUser!;
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? about,
  }) async {
    final payload = <String, dynamic>{};
    if (fullName != null) payload['full_name'] = fullName;
    if (email != null) payload['email'] = email;
    if (about != null) payload['about'] = about;

    final response = await dio.patch("/users/me", data: payload);
    _cachedUser = UserModel.fromJson(Map<String, dynamic>.from(response.data));
    return _cachedUser!;
  }

  Future<List<UserModel>> getAllUsers() async {
    final response = await dio.get("/users/");
    final List<dynamic> data = response.data;

    return data
        .map((user) => UserModel.fromJson(Map<String, dynamic>.from(user)))
        .where(
          (user) =>
              user.email.toLowerCase() != 'testuser123@example.com' &&
              user.fullName.trim().toLowerCase() != 'test user',
        )
        .toList();
  }

  Future<List<ConversationModel>> getConversations() async {
    final response = await dio.get("/conversations/");
    final List<dynamic> data = response.data;
    return data
        .map(
          (item) =>
              ConversationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<int> createConversation(int targetUserId) async {
    final response = await dio.post(
      "/conversations/",
      queryParameters: {"target_user_id": targetUserId},
    );
    return response.data['conversation_id'];
  }

  Future<Map<String, dynamic>> sendMessage(
    int conversationId,
    String content, {
    String? clientMsgId,
  }) async {
    final response = await dio.post(
      "/conversations/$conversationId/messages",
      data: {
        "content": content,
        if (clientMsgId != null) "client_msg_id": clientMsgId,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getMessages(
    int conversationId, {
    int? afterId,
  }) async {
    final response = await dio.get(
      "/conversations/$conversationId/messages",
      queryParameters: afterId != null ? {"after_id": afterId} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> editMessage(
    int conversationId,
    int messageId,
    String content,
  ) async {
    final response = await dio.patch(
      "/conversations/$conversationId/messages/$messageId",
      data: {"content": content},
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteMessage(int conversationId, int messageId) async {
    await dio.delete("/conversations/$conversationId/messages/$messageId");
  }

  Future<void> logout() async {
    _cachedUser = null;
    await storage.delete(key: "access_token");
  }
}
