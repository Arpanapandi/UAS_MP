import 'package:flutter/material.dart';
import '../model/Model_data-barang.dart';
import '../model/Model_data-peminjaman.dart';

class PeminjamanProvider with ChangeNotifier {
  final List<Peminjaman> _listPeminjaman = [];

  List<Peminjaman> get listPeminjaman => _listPeminjaman;

  void tambahPeminjaman(Item item, int jumlah) {
    _listPeminjaman.add(
      Peminjaman(
        id: DateTime.now().toString(),
        itemId: item.id,
        namaBarang: item.nama,
        jumlah: jumlah,
        tanggal: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void konfirmasiPengembalian(String id) {
    final index = _listPeminjaman.indexWhere((p) => p.id == id);
    if (index != -1) {
      _listPeminjaman[index].sudahDikembalikan = true;
      notifyListeners();
    }
  }

  // Hanya menampilkan peminjaman yang belum dikembalikan
  List<Peminjaman> get listBelumDikembalikan =>
      _listPeminjaman.where((p) => !p.sudahDikembalikan).toList();
}
