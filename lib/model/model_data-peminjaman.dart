class Peminjaman {
  final int id;
  final int barangId;
  final String namaBarang;
  final String namaPeminjam;
  final int jumlah;
  final DateTime tanggal;

  Peminjaman({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.namaPeminjam,
    required this.jumlah,
    required this.tanggal,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'],
      barangId: json['barang_id'],
      namaBarang: json['barang']['nama_barang'], // relasi
      namaPeminjam: json['nama_peminjam'],
      jumlah: int.parse(json['jumlah'].toString()),
      tanggal: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_peminjam': namaPeminjam,
      'barang_id': barangId.toString(),
      'jumlah': jumlah.toString(),
    };
  }
}
