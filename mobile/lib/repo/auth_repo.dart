import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepo {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000",
      headers: {"Content-Type": "application/json"},
    ),
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
}