import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/peminjaman.dart';
import 'api_services.dart';

class PeminjamanServices extends ChangeNotifier {
  final ApiServices _apiServices = ApiServices();
  
  List<Peminjaman> _peminjamanList = [];
  bool _isLoading = false;

  List<Peminjaman> get peminjamanList => _peminjamanList;
  bool get isLoading => _isLoading;

  Future<void> fetchPeminjaman() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiServices.dio.get('/peminjaman');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? response.data;
        _peminjamanList = data.map((e) => Peminjaman.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Peminjaman Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

    Future<bool> pinjamBarang(int barangId, String tanggalPinjam) async {
    try {
      final response = await _apiServices.dio.post('/peminjaman', data: {
        'barang_id': barangId,
        'tanggal_pinjam': tanggalPinjam,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchPeminjaman();
        return true;
      }
    } catch (e) {
      debugPrint('Pinjam Barang Error: $e');
    }
    return false;
  }

  Future<bool> kembalikanBarang(int peminjamanId) async {
    try {
      final response = await _apiServices.dio.post('/peminjaman/$peminjamanId/kembali');
      if (response.statusCode == 200) {
        await fetchPeminjaman(); // Refresh list
        return true;
      }
    } catch (e) {
      debugPrint('Kembalikan Barang Error: $e');
    }
    return false;
  }
}
