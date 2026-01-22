import 'dart:ui';
import 'package:aplikasi_project_uas/provider/peminjaman_provider.dart';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:aplikasi_project_uas/provider/item_provider.dart';
import 'package:aplikasi_project_uas/model/Model_data-barang.dart';

class DataBarang extends StatefulWidget {
  final bool isAdmin;
  DataBarang({super.key, this.isAdmin = false});

  @override
  State<DataBarang> createState() => _DataBarangState();
}

class _DataBarangState extends State<DataBarang> {
  List<int> jumlahPinjam = [];

  void _syncJumlahPinjam(int length) {
    if (jumlahPinjam.length != length) {
      jumlahPinjam = List.generate(length, (index) => 0);
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemProvider>(context, listen: false).fetchItems();
    });
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

  Widget _buildGlowSpot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.05),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final items = provider.items;

    _syncJumlahPinjam(items.length);

    if (provider.isLoading && items.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFF030712),
        body: _buildShimmerLoading(),
      );
    }

    if (provider.error != null && items.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFF030712),
        body: Center(
          child: Text("Error: ${provider.error}", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF030712),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlowSpot(250, Color.fromARGB(255, 36, 52, 77).withOpacity(0.15)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlowSpot(300, Color(0xFF8B5CF6).withOpacity(0.15)),
          ),

          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.white),
                    SizedBox(width: 10),
                    Text('PINJAM BARANG KAMPUS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: _showKeranjang,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              Text('Daftar Barang', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),

              SizedBox(height: 16),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];

                        return glassCard(
                          child: Column(
                            children: [
                              Expanded(
                                child: item.image.isNotEmpty
                                  ? Builder(
                                      builder: (context) {
                                        final String viewId = 'img-${item.id}';
                                        // ignore: undefined_prefixed_name
                                        ui.platformViewRegistry.registerViewFactory(
                                          viewId,
                                          (int id) => html.ImageElement()
                                            ..src = "${item.image}?v=${DateTime.now().millisecondsSinceEpoch}"
                                            ..style.width = '100%'
                                            ..style.height = '100%'
                                            ..style.objectFit = 'cover',
                                        );
                                        return HtmlElementView(viewType: viewId);
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey.shade800,
                                      child: const Icon(
                                        Icons.inventory_2,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                item.nama,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('Stok: ${item.stok}', style: TextStyle(color: Color(0xFF34D399))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Colors.white),
                                    onPressed: () => kurang(i),
                                  ),
                                  Text(
                                    jumlahPinjam[i].toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.white),
                                    onPressed: () => tambah(i, item.stok),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: jumlahPinjam[i] > 0
                                    ? () {_konfirmasiPinjam(provider, items[i], jumlahPinjam[i], i);}
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: jumlahPinjam[i] > 0 
                                    ? Colors.blueAccent 
                                    : Colors.grey,
                                  minimumSize: Size(double.infinity, 36),
                                ),
                                child: Text('Pinjam', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showKeranjang() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Color.fromARGB(255, 66, 77, 108),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Keranjang Pinjaman', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),

                Consumer<PeminjamanProvider>(
                  builder: (context, peminjamanProvider, _) {
                    final peminjaman = peminjamanProvider.listBelumDikembalikan;
                    if (peminjaman.isEmpty) {
                      return Text('Belum ada pinjaman', style: TextStyle(color: Colors.white54));
                    }
                    return Column(
                      children: peminjaman.map((p) {
                        return ListTile(
                          title: Text(p.namaBarang, style: TextStyle(color: Colors.white)),
                          trailing: Text('x${p.jumlah}', style: TextStyle(color: Colors.white70)),
                        );
                      }).toList(),
                    );
                  },
                ),

                SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _konfirmasiPinjam(
    ItemProvider provider,
    Item item,
    int jumlah,
    int index,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Konfirmasi Pinjam', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Apakah anda yakin akan meminjam barang ini?\n',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'Pengembalian atau pembatalan harus dikonfirmasi ke petugas perpustakaan.',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Ya')),
        ],
      ),
    );

    if (ok == true) {
      try {
        // REMOVED: provider.kurangiStok(item.id, jumlah: jumlah); 
        // Backend now handles stock decrement automatically on Laravel side.

        await Provider.of<PeminjamanProvider>(context, listen: false)
            .tambahPeminjaman(item, jumlah);

        // Refresh items to get updated stock from server
        await provider.fetchItems();

        setState(() {
          jumlahPinjam[index] = 0;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman berhasil dicatat'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal meminjam: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
