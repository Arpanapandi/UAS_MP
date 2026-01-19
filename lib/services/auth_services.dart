import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/user.dart';
import 'api_services.dart';

class AuthServices extends ChangeNotifier {
  final ApiServices _apiServices = ApiServices();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiServices.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token']; // Adjust key based on API response
        final userData = response.data['user']; // Adjust key based on API response
        
        await _storage.write(key: 'auth_token', value: token);
        _currentUser = User.fromJson(userData);
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Login Error: ${e.response?.data}');
      // Handle error message
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiServices.dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Auto login or return true to redirect to login
        return true;
      }
    } on DioException catch (e) {
       debugPrint('Register Error: ${e.response?.data}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> logout() async {
    try {
      await _apiServices.dio.post('/logout');
    } catch (e) {
      debugPrint('Logout Error: $e');
    }
    await _storage.delete(key: 'auth_token');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final response = await _apiServices.dio.get('/user'); // Adjust endpoint
        _currentUser = User.fromJson(response.data);
        notifyListeners();
      } catch (e) {
        // Token invalid
        await _storage.delete(key: 'auth_token');
      }
    }
  }
}
