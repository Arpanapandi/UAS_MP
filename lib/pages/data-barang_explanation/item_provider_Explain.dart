import 'package:aplikasi_project_uas/model/Model_data-barang.dart';
import 'package:flutter/material.dart';

class ItemProvider with ChangeNotifier {
  final List<Item> _items = [];
  final Map<Item, int> _keranjang = {}; // <- tambahkan keranjang

  List<Item> get items => _items;
  Map<Item, int> get keranjang => _keranjang; // getter keranjang

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


}
