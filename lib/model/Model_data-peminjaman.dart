class Peminjaman {
  final String id;
  final String itemId;
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
}
