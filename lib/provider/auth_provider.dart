import 'package:flutter/material.dart';
import 'package:aplikasi_project_uas/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;
  String? _token;
  final _storage = const FlutterSecureStorage();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get token => _token;

  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    
    // Here you might want to validate the token with the server or decode it
    // For now, we'll just assume it's valid and restore a session state
    _token = token;
    _currentUser = {'username': prefs.getString('username') ?? 'User'}; 
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.login(username, password);
      // Assuming response contains 'token' and 'user' info
      // Check if response structure matches what backend actually returns. 
      // Laravel Sanctum usually returns 'token' or 'access_token'.
      _token = response['token'] ?? response['access_token']; 
      _currentUser = response['user'] ?? {'username': username};
      
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await _storage.write(key: 'auth_token', value: _token);
        await prefs.setString('username', username);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
       final response = await AuthService.register(username, email, password);
       
       // Handle Direct Login after registration
       _token = response['token'] ?? response['access_token']; 
       _currentUser = response['user'] ?? {'username': username, 'email': email};
       
       if (_token != null) {
         final prefs = await SharedPreferences.getInstance();
         await _storage.write(key: 'auth_token', value: _token);
         await prefs.setString('username', username);
       }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    await _storage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
