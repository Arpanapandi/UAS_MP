import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/peminjaman_provider.dart';
import '../provider/item_provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  /// ================= GLOW SPOT =================
  Widget _buildGlowSpot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 150,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  /// ================= GLASS CARD =================
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final peminjaman =
        context.watch<PeminjamanProvider>().listPeminjaman;

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

          /// ================= CONTENT =================
          Column(
            children: [
              /// APPBAR
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Color(0xFF1E3A8A),
                  //     Color(0xFF312E81),
                  //   ],
                  // ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.history, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'DATA PEMINJAMAN',
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
                  child: peminjaman.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada data peminjaman',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: peminjaman.length,
                          itemBuilder: (context, index) {
                            final data = peminjaman[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: _glassCard(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration:
                                                BoxDecoration(
                                              color: Colors
                                                  .blueGrey
                                                  .shade800,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.inventory_2,
                                              color:
                                                  Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  data.namaBarang,
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Jumlah: ${data.jumlah}',
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${data.tanggal.day}/${data.tanggal.month}/${data.tanggal.year}',
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.white38,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 6),
                                                Text(
                                                  data.sudahDikembalikan
                                                      ? 'Dikembalikan'
                                                      : 'Dipinjam',
                                                  style: TextStyle(
                                                    color: data
                                                            .sudahDikembalikan
                                                        ? Colors
                                                            .greenAccent
                                                        : Colors
                                                            .yellowAccent,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (!data.sudahDikembalikan) ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              final itemProvider =
                                                  context.read<
                                                      ItemProvider>();
                                              final peminjamanProvider =
                                                  context.read<
                                                      PeminjamanProvider>();

                                              // 1. Tambah stok barang
                                              itemProvider.tambahStok(
                                                data.itemId,
                                                data.jumlah,
                                              );

                                              // 2. Reset keranjang
                                              itemProvider
                                                  .resetKeranjang();

                                              // 3. Konfirmasi pengembalian
                                              peminjamanProvider
                                                  .konfirmasiPengembalian(
                                                      data.id);
                                            },
                                            style:
                                                ElevatedButton
                                                    .styleFrom(
                                              backgroundColor:
                                                  Colors.white,
                                            ),
                                            child: Text(
                                                'Konfirmasi Pengembalian', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), ),
                                          ),
                                        ),
                                      ],
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
