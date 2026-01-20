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
    return Item(
      id: json["id"].toString(),
      nama: json["nama_barang"] ?? json["nama"] ?? "Unknown",
      stok: int.tryParse(json["stok"].toString()) ?? 0,
      image: json["image"] ?? json["gambar"] ?? "", 
      kategori: json["kategori"] ?? "Umum",
      keterangan: json["keterangan"] ?? json["description"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nama_barang": nama,
      "nama": nama,
      "stok": stok,
      "image": image,
      "kategori": kategori,
      "keterangan": keterangan,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Item && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
