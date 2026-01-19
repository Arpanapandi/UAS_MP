import 'package:aplikasi_project_uas/model/Model_data-barang.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_project_uas/services/API_services.dart';

class ItemProvider with ChangeNotifier {
  final List<Item> _items = [];
  final Map<Item, int> _keranjang = {};

  List<Item> get items => _items;
  Map<Item, int> get keranjang => _keranjang;

  bool isLoading = false;
  String? error;

  Future<void> fetchItems() async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await ApiService.getBarang();

      _items.clear();
      for (var item in res) {
        _items.add(Item.fromJson(item));
      }

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void tambahItem(Item item) {
    _items.add(item);
    notifyListeners();
  }

  void hapusItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void kurangiStok(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _items[index];
    if (item.stok <= 0) return;

    _items[index] = Item(
      id: item.id,
      nama: item.nama,
      stok: item.stok - 1,
      image: item.image, kategori: '',
    );

    notifyListeners();
  }

  // ================= KERANJANG =================
  void tambahKeranjang(Item item, int jumlah) {
    _keranjang[item] = (_keranjang[item] ?? 0) + jumlah;
    notifyListeners();
  }

  void resetKeranjang() {
    _keranjang.clear();
    notifyListeners();
  }

  void tambahStok(String itemId, int jumlah) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final item = _items[index];

    _items[index] = Item(
      id: item.id,
      nama: item.nama,
      stok: item.stok + jumlah,
      image: item.image, kategori: '',
    );

    notifyListeners();
  }

  void ubahItem(Item item) {}
}
