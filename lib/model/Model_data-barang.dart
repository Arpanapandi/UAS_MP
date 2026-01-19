class Item {
  final String id;
  final String nama;
  int stok;
  final String image;

  Item({
    required this.id,
    required this.nama,
    required this.stok,
    required this.image, required String kategori,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json["id"].toString(),
      nama: json["nama"] ?? "",
      stok: int.parse(json["stok"].toString()),
      image: json["image"] ?? "", 
      kategori: json["kategori"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama": nama,
      "stok": stok,
      "image": image,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Item && other.id == id);

  @override
  int get hashCode => id.hashCode;

  get kategori => null;
}
