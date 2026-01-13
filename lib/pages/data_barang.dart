import 'dart:ui';
import 'package:flutter/material.dart';

class DataBarang extends StatefulWidget {
  const DataBarang({super.key});

  @override
  State<DataBarang> createState() => _DataBarangState();
}

class _DataBarangState extends State<DataBarang> {
  final List<Map<String, dynamic>> items = [
    {"name": "Novel Hujan", "available": 12, "image": "https://via.placeholder.com/150"},
    {"name": "Al-Qur'an", "available": 5, "image": "https://via.placeholder.com/150"},
    {"name": "Buku Tulis", "available": 7, "image": "https://via.placeholder.com/150"},
    {"name": "Mini Whiteboard", "available": 4, "image": "https://via.placeholder.com/150"},
    {"name": "Buku Gambar", "available": 2, "image": "https://via.placeholder.com/150"},
    {"name": "Pensil", "available": 3, "image": "https://via.placeholder.com/150"},
  ];

  late List<int> jumlahPinjam;

  @override
  void initState() {
    super.initState();
    jumlahPinjam = List.generate(items.length, (_) => 0);
  }

  void tambah(int i) {
    if (jumlahPinjam[i] < items[i]["available"]) {
      setState(() => jumlahPinjam[i]++);
    }
  }

  void kurang(int i) {
    if (jumlahPinjam[i] > 0) {
      setState(() => jumlahPinjam[i]--);
    }
  }

  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Column(
        children: [

          /// APPBAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF312E81)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  "Pinjam Barang Perpustakaan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.handshake, color: Color(0xFF60A5FA)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// TITLE
          const Text(
            "Daftar Barang",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 16),

          /// GRID
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return glassCard(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(item["image"]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item["name"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stok: ${item["available"]}",
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                        ),
                      ),

                      /// COUNTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () => kurang(i),
                          ),
                          Text(
                            jumlahPinjam[i].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () => tambah(i),
                          ),
                        ],
                      ),

                      /// BUTTON
ElevatedButton(
  onPressed: jumlahPinjam[i] > 0 ? () {} : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: jumlahPinjam[i] > 0
        ? const Color(0xFF60A5FA) // aktif
        : Colors.white.withOpacity(0.08), // nonaktif tapi keliatan
    disabledBackgroundColor: Colors.white.withOpacity(0.08),
    foregroundColor: jumlahPinjam[i] > 0
        ? Colors.white
        : Colors.white54,
    disabledForegroundColor: Colors.white54,
  ),
  child: const Text("Pinjam"),
),

                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
