import 'package:aplikasi_project_uas/services/API_services.dart';

class BarangService {
  static Future<List<dynamic>> getAllBarang() async {
    final response = await ApiService.get("barang");
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    if (response is List) {
      return response;
    }
    return [];
  }

  static Future<Map<String, dynamic>> createBarang(Map<String, dynamic> data) async {
    final response = await ApiService.post("barang", data);
    return response;
  }

  static Future<Map<String, dynamic>> updateBarang(String id, Map<String, dynamic> data) async {
    final response = await ApiService.put("barang/$id", data);
    return response;
  }

  static Future<void> deleteBarang(String id) async {
    await ApiService.delete("barang/$id");
  }
  
  static Future<Map<String, dynamic>> updateStok(String id, int newStok) async {
      // Backend uses standard resource update. Sending partial data might need PATCH or full PUT.
      // Trying PUT with just stock, if backend fails we might need to fetch-then-update.
      final response = await ApiService.put("barang/$id", {"stok": newStok});
      return response;
  }
}
