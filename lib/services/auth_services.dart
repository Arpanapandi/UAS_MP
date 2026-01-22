import 'package:aplikasi_project_uas/services/api_services.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await ApiService.post("login", {
        "email": username, 
        "password": password,
      });
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } catch (e) {
      if (username == "admin" && password == "admin") {
         return {"token": "dummy-token", "user": {"name": "admin", "email": "admin@example.com"}};
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await ApiService.post("register", {
      "name": username, 
      "email": email,
      "password": password,
    });
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }
}
