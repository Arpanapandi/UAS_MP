import 'package:aplikasi_project_uas/model/Model_data-barang.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_project_uas/services/barang_services.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:image_picker/image_picker.dart'; // XFile
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemProvider with ChangeNotifier {
  final List<Item> _items = [];
  final Map<Item, int> _keranjang = {};

  List<Item> get items => _items;
  Map<Item, int> get keranjang => _keranjang;

  bool isLoading = false;
  String? error;

  static const String _cacheKey = 'items_cache';

  ItemProvider() {
    _loadCache();
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        _items.clear();
        for (var item in decoded) {
          _items.add(Item.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Cache load error: $e");
    }
  }

  Future<void> _saveCache(List<dynamic> rawData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(rawData));
    } catch (e) {
      debugPrint("Cache save error: $e");
    }
  }

  Future<void> fetchItems() async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await BarangService.getAllBarang();

      _items.clear();
      for (var item in res) {
        _items.add(Item.fromJson(item));
      }

      await _saveCache(res);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tambahItem(Item item, {XFile? imageFile}) async {
    try {
      isLoading = true;
      notifyListeners();
      
      dynamic data;
      if (imageFile != null) {
        String fileName = imageFile.name;
        String ext = fileName.split('.').last.toLowerCase();
        if (ext == 'jpg') ext = 'jpeg';
        
        MultipartFile multipartFile;
        if (kIsWeb) {
             multipartFile = MultipartFile.fromBytes(
               await imageFile.readAsBytes(),
               filename: fileName,
               contentType: MediaType('image', ext),
             );
        } else {
             multipartFile = await MultipartFile.fromFile(
               imageFile.path, 
               filename: fileName,
               contentType: MediaType('image', ext),
             );
        }

        data = FormData.fromMap({
          "nama_barang": item.nama,
          "stok": item.stok.toString(),
          "kategori": item.kategori,
          "keterangan": item.keterangan,
          "gambar": multipartFile,
        });
      } else {
        data = {
          "nama_barang": item.nama,
          "stok": item.stok.toString(),
          "kategori": item.kategori,
          "keterangan": item.keterangan,
        };
      }

      await BarangService.createBarang(data);
      
      // Refresh strictly from server to verify actual persistence
      await fetchItems(); 
      
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
        keterangan: item.keterangan,
      );
      notifyListeners();

      // Ensure we send 'gambar' so it doesn't get set to NULL in DB
      String? fileName = item.image.isNotEmpty ? item.image.split('/').last : null;
      await BarangService.updateBarang(id, {
        ..._items[index].toJson(),
        "gambar": fileName,
        "image": fileName,
      });
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
        keterangan: item.keterangan,
      );
      notifyListeners();
      
      String? fileName = item.image.isNotEmpty ? item.image.split('/').last : null;
      await BarangService.updateBarang(itemId, {
        ..._items[index].toJson(),
        "gambar": fileName,
        "image": fileName,
      });
    } catch (e) {
        // Rollback
       _items[index] = item;
       notifyListeners();
       rethrow;
    }
  }

  Future<void> ubahItem(Item item, {XFile? imageFile}) async {
     try {
       isLoading = true;
       notifyListeners();
       
       dynamic data;
       bool isMultipart = false;

       if (imageFile != null) {
         isMultipart = true;
         
         String fileName = imageFile.name;
         String ext = fileName.split('.').last.toLowerCase();
         if (ext == 'jpg') ext = 'jpeg';

         MultipartFile multipartFile;
         if (kIsWeb) {
              multipartFile = MultipartFile.fromBytes(
                await imageFile.readAsBytes(),
                filename: fileName,
                contentType: MediaType('image', ext),
              );
         } else {
              multipartFile = await MultipartFile.fromFile(
                imageFile.path, 
                filename: fileName,
                contentType: MediaType('image', ext),
              );
         }

          data = FormData.fromMap({
            "nama_barang": item.nama,
            "stok": item.stok.toString(),
            "kategori": item.kategori,
            "keterangan": item.keterangan,
            "gambar": multipartFile,
            "_method": "PUT",
          });
        } else {
          data = {
            "nama_barang": item.nama,
            "stok": item.stok.toString(),
            "kategori": item.kategori,
            "keterangan": item.keterangan,
          };
        }

       await BarangService.updateBarang(item.id, data, isMultipart: isMultipart);
       
       PaintingBinding.instance.imageCache.clear();
       PaintingBinding.instance.imageCache.clearLiveImages();
       
       // Refresh strictly from server
       await fetchItems(); 
       
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
