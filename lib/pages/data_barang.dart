import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/item_provider.dart';
import '../model/Model-data_barang.dart';

class DataBarang extends StatefulWidget {
  DataBarang({super.key});

  @override
  State<DataBarang> createState() => _DataBarangState();
}

class _DataBarangState extends State<DataBarang> {
  List<int> jumlahPinjam = [];
  final Map<Item, int> keranjang = {};

  void _syncJumlahPinjam(int length) {
    if (jumlahPinjam.length != length) {
      jumlahPinjam = List.generate(length, (_) => 0);
    }
  }

  void tambah(int i, int stok) {
    if (jumlahPinjam[i] < stok) {
      setState(() => jumlahPinjam[i]++);
    }
  }

  void kurang(int i) {
    if (jumlahPinjam[i] > 0) {
      setState(() => jumlahPinjam[i]--);
    }
  }

  /// ================= KERANJANG =================
  void _showKeranjang() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF030712),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Keranjang Pinjaman', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            keranjang.isEmpty
                ? Text(
                    'Belum ada pinjaman',
                    style: TextStyle(color: Colors.white54),
                  )
                : Column(
                    children: keranjang.entries.map((e) {
                      return ListTile(
                        title: Text(e.key.nama, style: TextStyle(color: Colors.white)),
                        trailing: Text('x${e.value}', style: TextStyle(color: Colors.white70)),
                      );
                    }).toList(),
                  ),
            Text("Notes : Hubungi Petugas Perpustakaan jika ingin mengembalikan barang", style: TextStyle(color: Colors.white),)
          ],
        ),
      ),
    );
  }

  /// ================= KONFIRMASI =================
  Future<void> _konfirmasiPinjam(
    ItemProvider provider,
    Item item,
    int jumlah,
    int index,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Konfirmasi Pinjam'),
        content: Text(
          'Apakah anda yakin akan meminjam barang ini?\n\n'
          'Pengembalian atau pembatalan harus dikonfirmasi ke petugas perpustakaan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Ya'),
          ),
        ],
      ),
    );

    if (ok == true) {
      for (int i = 0; i < jumlah; i++) {
        provider.kurangiStok(item.id);
      }

      setState(() {
        keranjang[item] = (keranjang[item] ?? 0) + jumlah;
        jumlahPinjam[index] = 0;
      });
    }
  }

  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.all(12),
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
    final provider = context.watch<ItemProvider>();
    final items = provider.items;

    _syncJumlahPinjam(items.length);

    return Scaffold(
      backgroundColor: Color(0xFF030712),
      body: Column(
        children: [
          /// APPBAR
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF312E81)],
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.white),
                SizedBox(width: 10),
                Text('Pinjam Barang Perpustakaan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Spacer(),

                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: _showKeranjang,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          Text('Daftar Barang', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),

          SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];

                return glassCard(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(item.image, fit: BoxFit.cover),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Stok: ${item.stok}', style: const TextStyle(color: Color(0xFF34D399))),
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
                            onPressed: () => tambah(i, item.stok),
                          ),

                        ],
                      ),
                      ElevatedButton(
                        onPressed: jumlahPinjam[i] > 0
                            ? () => _konfirmasiPinjam(
                                  provider,
                                  item,
                                  jumlahPinjam[i],
                                  i,
                                )
                            : null,
                        child: Text('Pinjam'),
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
