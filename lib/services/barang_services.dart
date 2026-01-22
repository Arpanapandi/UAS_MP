import 'package:aplikasi_project_uas/services/api_services.dart';

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

  static Future<Map<String, dynamic>> createBarang(dynamic data) async {
    final response = await ApiService.post("barang", data);
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  static Future<Map<String, dynamic>> updateBarang(String id, dynamic data, {bool isMultipart = false}) async {
    // Always use POST with _method = PUT to avoid connection issues with PUT method
    // (Common issue with CORS or incomplete server configurations)
    if (isMultipart) {
      // Data is already FormData, ensure _method is added in caller or here if needed
      // (Caller in item_provider usually handles creating FormData, but we can't easily append to it here if it's already finalized)
      // Assuming caller handles _method for multipart or it's standard POST update
      
      // Actually, standard Laravel resource update via multipart MUST have _method = PUT field.
      // ItemProvider.ubahItem does adds "_method": "PUT" for multipart.
      
      final response = await ApiService.post("barang/$id", data);
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    } else {
      // For JSON updates, we switch to POST + _method: PUT
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      payload['_method'] = 'PUT';

      final response = await ApiService.post("barang/$id", payload);
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      }
      return response;
    }
  }

  static Future<void> deleteBarang(String id) async {
    await ApiService.delete("barang/$id");
  }
  
  static Future<Map<String, dynamic>> updateStok(String id, int newStok) async {
      // Use POST with _method = PUT
      final response = await ApiService.post("barang/$id", {
        "stok": newStok,
        "_method": "PUT"
      });
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      }
      return response;
  }
}
