import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiServices {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Replace with your actual Laravel API URL
  // If running on emulator verify 10.0.2.2 or your machine IP
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  ApiServices() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add interceptor to include Bearer token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors here if needed (e.g. 401 Unauthorized)
        debugPrint('API Error: ${e.message}');
        if (e.response != null) {
          debugPrint('API Error Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
