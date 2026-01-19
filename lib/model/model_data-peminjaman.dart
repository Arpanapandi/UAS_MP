class DataPeminjaman {
  final int id;
  final String namaPeminjam;
  final String namaBarang;
  final int jumlah;

  DataPeminjaman({
    required this.id,
    required this.namaPeminjam,
    required this.namaBarang,
    required this.jumlah,
  });

  factory DataPeminjaman.fromJson(Map<String, dynamic> json) {
    return DataPeminjaman(
      id: json['id'],
      namaPeminjam: json['nama_peminjam'],
      namaBarang: json['nama_barang'],
      jumlah: int.parse(json['jumlah'].toString()),
    );
  }
}
