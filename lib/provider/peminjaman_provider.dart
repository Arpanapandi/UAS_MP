import 'package:flutter/material.dart';
import '../model/Model_data-barang.dart';
import '../model/Model_data-peminjaman.dart';
import '../services/peminjaman_services.dart';

class PeminjamanProvider with ChangeNotifier {
  List<Peminjaman> _listPeminjaman = [];
  bool isLoading = false;
  String? error;

  List<Peminjaman> get listPeminjaman => _listPeminjaman;

  Future<void> fetchPeminjaman() async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await PeminjamanService.getPeminjaman();
      
      _listPeminjaman = List.from(res).map((item) {
          return Peminjaman.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> tambahPeminjaman(Item item, int jumlah) async {
    try {
        final newPeminjamanData = {
            "barang_id": item.id,
            "jml_peminjaman": jumlah,
            "tanggal_pinjam": DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD
            "status": "dipinjam"
        };
        
        await PeminjamanService.catatPeminjaman(newPeminjamanData);
        await fetchPeminjaman(); 
    } catch (e) {
        error = e.toString();
        notifyListeners();
        rethrow;
    }
  }

  Future<void> konfirmasiPengembalian(String id) async {
      try {
          await PeminjamanService.kembalikanBarang(id);
          final index = _listPeminjaman.indexWhere((p) => p.id == id);
          if (index != -1) {
              _listPeminjaman[index].sudahDikembalikan = true;
              notifyListeners();
          }
      } catch (e) {
          error = e.toString();
          notifyListeners();
      }
  }

  List<Peminjaman> get listBelumDikembalikan =>
      _listPeminjaman.where((p) => !p.sudahDikembalikan).toList();
}
