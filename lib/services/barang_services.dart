import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/barang.dart';
import 'api_services.dart';

class BarangServices extends ChangeNotifier {
  final ApiServices _apiServices = ApiServices();
  
  List<Barang> _barangList = [];
  bool _isLoading = false;

  List<Barang> get barangList => _barangList;
  bool get isLoading => _isLoading;

  Future<void> fetchBarang() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiServices.dio.get('/barang');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? response.data; // Adjust based on API structure
        _barangList = data.map((e) => Barang.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Barang Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBarang(Barang barang) async {
    try {
      final response = await _apiServices.dio.post('/barang', data: barang.toJson()..remove('id'));
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchBarang();
        return true;
      }
    } catch (e) {
      debugPrint('Add Barang Error: $e');
    }
    return false;
  }
    
  Future<bool> updateBarang(int id, Barang barang) async {
    try {
      final response = await _apiServices.dio.put('/barang/$id', data: barang.toJson());
      if (response.statusCode == 200) {
        await fetchBarang();
        return true;
      }
    } catch (e) {
      debugPrint('Update Barang Error: $e');
    }
    return false;
  }

  Future<bool> deleteBarang(int id) async {
    try {
      final response = await _apiServices.dio.delete('/barang/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchBarang();
        return true;
      }
    } catch (e) {
      debugPrint('Delete Barang Error: $e');
    }
    return false;
  }
}
