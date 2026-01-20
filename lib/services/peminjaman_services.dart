import 'package:aplikasi_project_uas/services/API_services.dart';

class PeminjamanService {
  static Future<List<dynamic>> getPeminjaman() async {
    final response = await ApiService.get("peminjaman");
    if (response is Map && response.containsKey('data')) {
      if (response['data'] is List) {
        return response['data'];
      }
    }
    if (response is List) {
      return response;
    }
    return [];
  }
  
  static Future<List<dynamic>> getPeminjamanByUsermame(String username) async {
      final response = await ApiService.get("peminjaman?username=$username");
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      }
      return response is List ? response : [];
  }

  static Future<Map<String, dynamic>> catatPeminjaman(Map<String, dynamic> data) async {
    final response = await ApiService.post("peminjaman", data);
    return response;
  }

  static Future<void> kembalikanBarang(String id) async {
    // Backend uses standard resource update for status
    await ApiService.put("peminjaman/$id", {"status": "dikembalikan"});
  }
}
