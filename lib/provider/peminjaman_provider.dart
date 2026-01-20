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
      // Assuming response is list of Peminjaman like objects
      // Note: Model_data-peminjaman.dart needs to be checked if it has fromJson
      // If not, we might need to map manual or update model. 
      // Assuming Peminjaman.fromJson exists or constructor can be used.
      // But Peminjaman model from step 15 was empty? Wait, step 15 showed list dir.
      // Step 24 showed model data barang. Step 32 showed item provider.
      // I haven't seen Peminjaman model content fully. 
      // Step 33 showed PeminjamanProvider using Peminjaman model.
      // Step 33 showed:
      // Peminjaman(id: ..., itemId: ..., namaBarang: ..., jumlah: ..., tanggal: ...)
      
      _listPeminjaman = List.from(res).map((item) {
          if (item is Map) {
            return Peminjaman.fromJson(Map<String, dynamic>.from(item));
          }
          // Fallback if needed, though fromJson handles it
          return Peminjaman(
              id: item['id'].toString(),
              itemId: item['barang_id']?.toString() ?? item['itemId']?.toString() ?? '',
              namaBarang: item['nama_barang'] ?? item['namaBarang'] ?? '',
              jumlah: int.tryParse(item['jumlah'].toString()) ?? 0,
              tanggal: DateTime.tryParse(item['tanggal'] ?? item['created_at'] ?? '') ?? DateTime.now(),
              sudahDikembalikan: item['status'] == 'dikembalikan'
          );
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
            "jumlah": jumlah,
            "tanggal_pinjam": "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}", // YYYY-MM-DD format for Laravel date validation
            "status": "dipinjam"
        };
        
        await PeminjamanService.catatPeminjaman(newPeminjamanData);
        await fetchPeminjaman(); // Refresh list from server
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

  // Hanya menampilkan peminjaman yang belum dikembalikan
  List<Peminjaman> get listBelumDikembalikan =>
      _listPeminjaman.where((p) => !p.sudahDikembalikan).toList();
}
