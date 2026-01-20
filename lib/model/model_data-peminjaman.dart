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
    return Peminjaman(
      id: json['id'].toString(),
      itemId: json['itemId']?.toString() ?? json['barang_id']?.toString() ?? '',
      namaBarang: json['namaBarang'] ?? json['nama_barang'] ?? json['barang']?['nama'] ?? 'Unknown',
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      tanggal: DateTime.tryParse(json['tanggal'] ?? json['created_at'] ?? '') ?? DateTime.now(),
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
