import 'package:app/model/usser_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepo {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  late  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000",
      headers: {"Content-Type": "application/json"},
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async{
          final token =await storage.read(
            key: "access_token",
            );
            if(token != null && token.isNotEmpty){
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
      }
    )
  );
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

  Future<UserModel> getCurrent() async{
    final response =await dio.get(
      "/users/me",
    );
    return UserModel.fromJson(
      Map<String,dynamic>.from(response.data)
    );
  }

  Future<List<UserModel>> getAllUsers() async {
    final response =await dio.get("/users/");
    final List<dynamic> data =response.data;

    return data.map((user){
      return UserModel.fromJson(user);
    }).toList();
  }
  Future<int> createConversation(int targetUserId) async{
    final response =await dio.post(
      "/conversations/",
      queryParameters: {
        "target_user_id":targetUserId,
      },
    );
    return response.data['conversation_id'];
  }
  Future<void> sendMessage(
    int conversationId,
    String content,
  ) async{
    await dio.post(
      "/conversations/$conversationId/messages",  
      data: {
        "content" : content,
      }
    );
  }
  Future<List<dynamic>> getMessages(int conversationId) async {
    final response = await dio.get(
      "/conversations/$conversationId/messages"
    );
    return response.data;
  }
  Future<void> logout() async{
    await storage.delete(key: "access_token");  
  }
}