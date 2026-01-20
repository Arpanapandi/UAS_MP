import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // GANTI PORT INI SESUAI BACKEND ANDA (8000 untuk Laravel serve, 80 untuk XAMPP default)
  static const String port = "8000"; 
  static const String ip = "10.14.180.142";
  static const String baseUrl = "http://$ip:$port/api";
  
  static const Duration timeoutDuration = Duration(seconds: 30); // Timeout connection increased

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }


  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    try {
      final headers = await getHeaders();
      final response = await http
          .get(url, headers: headers)
          .timeout(timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Connection Error: $e");
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    try {
      final headers = await getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Connection Error: $e");
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    try {
      final headers = await getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        url,
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
       // Handle 204 No Content which might return empty body
      if (response.body.isEmpty) return {};
      try {
        return jsonDecode(response.body);
      } catch (e) {
        // If 200 OK but not JSON (e.g. plain text), return raw body or empty map? 
        // Safer to just return body as is if expectation is flexible, or empty.
        // For this app, let's assume valid JSON.
        throw Exception("Invalid JSON Response: ${response.body}");
      }
    } else {
      // Try to parse friendly error message
      String message = "API Error ${response.statusCode}";
      try {
        final body = jsonDecode(response.body);
        if (body is Map) {
          if (body.containsKey('message')) {
            message = body['message'];
          }
          if (body.containsKey('errors')) {
            // Laravel Validation Errors: "errors": {"email": ["Email taken"]}
            final errors = body['errors'];
            if (errors is Map) {
              final errorList = errors.values.map((e) => e.toString()).join(', ');
              message += " ($errorList)";
            }
          }
        }
      } catch (_) {
        // Fallback to raw body if not JSON
        message += ": ${response.body}";
      }
      throw Exception(message);
    }
  }

  // Legacy method for backward compatibility if needed, but we should use generics
  static Future<List<dynamic>> getBarang() async {
    final res = await get("barang");
    // Ensure we handle the "data" wrapper if API returns {data: []}
    if (res is Map && res.containsKey('data')) {
      return res['data'] is List ? res['data'] : [];
    }
    return res is List ? res : [];
  }
}
