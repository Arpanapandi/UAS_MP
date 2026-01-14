class Item {
  final String id;
  final String nama;
  final int stok;
  final String image;

  Item({
    required this.id,
    required this.nama,
    required this.stok,
    required this.image,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      nama: json['name'],
      stok: json['available'],
      image: json['image'],
    );
  }
}
