import 'package:aplikasi_project_uas/model/Model_data-barang.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_project_uas/services/barang_services.dart';

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

      final res = await BarangService.getAllBarang();

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

  Future<void> tambahItem(Item item) async {
    try {
      isLoading = true;
      notifyListeners();
      
      final newItemData = await BarangService.createBarang(item.toJson());
      _items.add(Item.fromJson(newItemData));
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> hapusItem(String id) async {
    try {
      await BarangService.deleteBarang(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> kurangiStok(String id, {int jumlah = 1}) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    
    final item = _items[index];
    if (item.stok < jumlah) {
      throw Exception("Stok tidak cukup");
    }

    final newStok = item.stok - jumlah;

    try {
      // Optimistic update
      _items[index] = Item(
        id: item.id,
        nama: item.nama,
        stok: newStok,
        image: item.image, 
        kategori: item.kategori,
      );
      notifyListeners();

      await BarangService.updateBarang(id, _items[index].toJson());
    } catch (e) {
       // Rollback if failed
      _items[index] = item;
      notifyListeners();
      throw Exception("Gagal update stok: $e");
    }
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

  Future<void> tambahStok(String itemId, int jumlah) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final item = _items[index];
    final newStok = item.stok + jumlah;

     try {
       // Optimistic update
      _items[index] = Item(
        id: item.id,
        nama: item.nama,
        stok: newStok,
        image: item.image, 
        kategori: item.kategori,
      );
      notifyListeners();
      
      await BarangService.updateBarang(itemId, _items[index].toJson());
    } catch (e) {
        // Rollback
       _items[index] = item;
       notifyListeners();
       rethrow;
    }
  }

  Future<void> ubahItem(Item item) async {
     try {
       isLoading = true;
       notifyListeners();
       
       await BarangService.updateBarang(item.id, item.toJson());
       
       final index = _items.indexWhere((i) => i.id == item.id);
       if (index != -1) {
         _items[index] = item;
       }
       
       isLoading = false;
       notifyListeners();
     } catch (e) {
       isLoading = false;
       error = e.toString();
       notifyListeners();
       rethrow;
     }
  }
}
