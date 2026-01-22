class Peminjaman {
  final String id;
  final String itemId; // Unified to itemId
  final String namaBarang;
  final int jumlah;
  final DateTime tanggal;
  bool sudahDikembalikan;

  Peminjaman({
    required this.id,
    required this.itemId,
    required this.namaBarang,
    required this.jumlah,
    required this.tanggal,
    this.sudahDikembalikan = false,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    // Determine the product name from various common structures
    String name = 'Unknown';
    if (json['nama_barang'] != null) {
      name = json['nama_barang'];
    } else if (json['namaBarang'] != null) {
      name = json['namaBarang'];
    } else if (json['barang'] != null) {
      if (json['barang'] is Map) {
         name = json['barang']['nama_barang'] ?? json['barang']['nama'] ?? 'Unknown';
      }
    }

    return Peminjaman(
      id: json['id'].toString(),
      itemId: json['barang_id']?.toString() ?? json['itemId']?.toString() ?? '',
      namaBarang: name,
      jumlah: int.tryParse(json['jumlah'].toString()) ?? int.tryParse(json['qty'].toString()) ?? 0,
      tanggal: DateTime.tryParse(json['tanggal_pinjam'] ?? json['tanggal'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      sudahDikembalikan: json['status'] == 'dikembalikan' || json['sudahDikembalikan'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'namaBarang': namaBarang,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'status': sudahDikembalikan ? 'dikembalikan' : 'dipinjam',
    };
  }
}
