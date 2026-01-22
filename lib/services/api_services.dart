import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  // Replace with your actual Laravel API URL
  // If running on emulator verify 10.0.2.2 or your machine IP
  // Use localhost for web to avoid network complexity
  
  // CHANGE YOUR IP HERE IF USING PHYSICAL DEVICE
  static const String serverIp = '172.20.10.2'; 
  static const String baseServerUrl = 'http://$serverIp:8000';
  final String baseUrl = '$baseServerUrl/api/'; 

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Interceptor to add Bearer token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
         debugPrint('API Error [${e.response?.statusCode}]: ${e.message}');
         return handler.next(e);
      }
    ));
  }

  static Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _instance._dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  static Future<dynamic> post(String path, dynamic data) async {
    try {
      final response = await _instance._dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  static Future<dynamic> put(String path, dynamic data) async {
    try {
      final response = await _instance._dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  static void _handleDioError(DioException e) {
    String message = "Connection error";
    
    if (e.type == DioExceptionType.connectionTimeout) {
      message = "Connection timeout. Please check your server or network.";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = "Server is taking too long to respond.";
    } else if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      if (responseData is Map) {
        message = responseData['message'] ?? responseData['error'] ?? "Error $statusCode";
        if (responseData['errors'] != null) {
          message += ": " + responseData['errors'].toString();
        }
      } else {
        message = "Server error ($statusCode)";
      }
    } else {
      message = "Network error: ${e.message}";
    }
    
    debugPrint('DIO ERROR [${e.type}]: $message');
    throw Exception(message);
  }

  static Future<dynamic> delete(String path) async {
    final response = await _instance._dio.delete(path);
    return response.data;
  }
}
