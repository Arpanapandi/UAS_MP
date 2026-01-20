import 'package:aplikasi_project_uas/services/API_services.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await ApiService.post("login", {
        "email": username, // Backend likely expects 'email' key
        "password": password,
      });
      return response;
    } catch (e) {
      // For development fallback if API is not ready
      if (username == "admin" && password == "admin") {
         return {"token": "dummy-token", "user": {"name": "admin", "email": "admin@example.com"}};
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await ApiService.post("register", {
      "name": username, // Standard Laravel register usually expects 'name'
      "email": email,
      "password": password,
      "password_confirmation": password, // Often required
    });
    return response;
  }
}
