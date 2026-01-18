import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/peminjaman_provider.dart';
import '../provider/item_provider.dart';

class PeminjamanBarangPage extends StatelessWidget {
  const PeminjamanBarangPage({super.key});


  Widget _buildGlowSpot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 150, spreadRadius: 50),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
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
    final peminjamanProvider = context.watch<PeminjamanProvider>();
    final itemProvider = context.read<ItemProvider>();

    final data = peminjamanProvider.listBelumDikembalikan;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlowSpot(
              250,
              const Color(0xFF3B82F6).withOpacity(0.15),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlowSpot(
              300,
              const Color(0xFF8B5CF6).withOpacity(0.15),
            ),
          ),

          Column(
            children: [
              /// APPBAR
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: const [
                    Icon(Icons.assignment, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'PEMINJAMAN AKTIF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: data.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada peminjaman aktif',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final pinjam = data[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _glassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.blueGrey.shade800,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.inventory_2,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pinjam.namaBarang,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Jumlah: ${pinjam.jumlah}',
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${pinjam.tanggal.day}/${pinjam.tanggal.month}/${pinjam.tanggal.year}',
                                                  style: const TextStyle(
                                                    color: Colors.white38,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            itemProvider.tambahStok(
                                              pinjam.itemId,
                                              pinjam.jumlah,
                                            );
                                            
                                            peminjamanProvider
                                                .konfirmasiPengembalian(
                                                    pinjam.id);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                          ),
                                          child: const Text(
                                            'Kembalikan Barang',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
