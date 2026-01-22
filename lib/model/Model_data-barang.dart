import 'package:flutter/material.dart';
import 'package:aplikasi_project_uas/services/api_services.dart';

class Item {
  final String id;
  final String nama;
  int stok;
  final String image;
  final String kategori;
  final String keterangan;

  Item({
    required this.id,
    required this.nama,
    required this.stok,
    required this.image,
    required this.kategori,
    this.keterangan = '',
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    String rawImage = json["image"] ?? json["gambar"] ?? "";
    String imageUrl = "";
    if (rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        imageUrl = rawImage;
      } else {
        // Fallback for relative paths if needed, 
        // though backend is expected to send absolute URLs now.
        final String baseUrl = ApiService.baseServerUrl; 
        if (rawImage.startsWith('/')) {
            imageUrl = "$baseUrl$rawImage";
        } else {
            imageUrl = "$baseUrl/images/barang/$rawImage";
        }
      }
      debugPrint("DEBUG: Image URL for '${json['nama_barang'] ?? 'Item'}': $imageUrl");
    }

    return Item(
      id: json["id"].toString(),
      nama: json["nama_barang"] ?? json["nama"] ?? "Unknown",
      stok: int.tryParse(json["stok"].toString()) ?? 0,
      image: imageUrl, 
      kategori: json["kategori"] ?? "Umum",
      keterangan: json["keterangan"] ?? json["description"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nama_barang": nama,
      "stok": stok,
      "gambar": image.split('/').last,
      "image": image.split('/').last,
      "kategori": kategori,
      "keterangan": keterangan,
      "description": keterangan,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Item && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
