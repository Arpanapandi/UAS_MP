class Item {
  final String id;
  final String nama;
  int stok;
  final String image;

  Item({
    required this.id,
    required this.nama,
    required this.stok,
    required this.image,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Item && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
