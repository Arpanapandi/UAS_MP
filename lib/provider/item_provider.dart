import 'package:aplikasi_project_uas/model/Model-data_barang.dart';
import 'package:flutter/material.dart';


class ItemProvider with ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => _items;

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
      image: item.image,
    );

    notifyListeners();
  }
}
