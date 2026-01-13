import 'package:flutter/material.dart';

class DataBarang extends StatefulWidget {
  DataBarang({super.key});

  @override
  State<DataBarang> createState() => _DataBarangState();
}

class _DataBarangState extends State<DataBarang> {
  final List<Map<String, dynamic>> items = [
    {"name": "novel hujan yang jatuh dari langit", "available": 12, "image": "https://via.placeholder.com/150"},
    {"name": "alqur'an", "available": 5, "image": "https://via.placeholder.com/150"},
    {"name": "buku tulis", "available": 7, "image": "https://via.placeholder.com/150"},
    {
      "name": "mini whiteboard",
      "available": 4,
      "image": "https://via.placeholder.com/150?text=Kursi",
    },
    {
      "name": "buku gambar",
      "available": 2,
      "image": "https://via.placeholder.com/150?text=Layar",
    },
    {
      "name": "pensil",
      "available": 3,
      "image": "https://via.placeholder.com/150?text=Speaker",
    },
  ];

  late List<int> jumlahPinjam;

  @override
  void initState() {
    super.initState();
    jumlahPinjam = List.generate(items.length, (index) => 0);
  }

  void tambah(int index) {
    if (jumlahPinjam[index] < items[index]["available"]) {
      setState(() {
        jumlahPinjam[index]++;
      });
    }
  }

  void kurang(int index) {
    if (jumlahPinjam[index] > 0) {
      setState(() {
        jumlahPinjam[index]--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// ================= APPBAR =================
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2F66D0), Color(0xFF3F7BE0)],
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.white),
              SizedBox(width: 8),
              Text("Pinjam Barang Perpustakaan",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Spacer(),
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    shape: CircleBorder(),
    padding: EdgeInsets.all(10),
  ),
  child: Icon(Icons.library_books, color: Color.fromARGB(255, 29, 123, 253))
),

            ],
          ),
        ),

        /// ================= BODY ATAS =================
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Daftar Barang",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),

        /// ================= GRID BARANG =================
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(item["image"]),
                      ),
                      Text(
                        item["name"],
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text("Stok: ${item["available"]}"),

                      /// COUNTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => kurang(index),
                            icon: Icon(Icons.remove),
                          ),
                          Text(jumlahPinjam[index].toString()),
                          IconButton(
                            onPressed: () => tambah(index),
                            icon: Icon(Icons.add),
                          ),
                        ],
                      ),

                      ElevatedButton(
                        onPressed: jumlahPinjam[index] > 0 ? () {} : null,
                        child: Text("Pinjam"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
