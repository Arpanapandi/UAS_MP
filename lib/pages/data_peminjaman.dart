import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/peminjaman_provider.dart';
import '../provider/item_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PeminjamanProvider>(context, listen: false).fetchPeminjaman();
    });
  }

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
    // ... rest of build method
    final provider = context.watch<PeminjamanProvider>();
    final peminjaman = provider.listPeminjaman;

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
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${provider.error}',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => provider.fetchPeminjaman(),
                                  child: const Text('Coba Lagi'),
                                )
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => provider.fetchPeminjaman(),
                            child: peminjaman.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Belum ada data peminjaman',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
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
                                            onPressed: () async {
                                              final itemProvider =
                                                  context.read<
                                                      ItemProvider>();
                                              final peminjamanProvider =
                                                  context.read<
                                                      PeminjamanProvider>();

                                              // 1. REMOVED: itemProvider.tambahStok(data.itemId, data.jumlah);
                                              // Backend handles stock increment on Laravel side when status updated to 'dikembalikan'

                                              // 2. Reset keranjang
                                              itemProvider.resetKeranjang();

                                              // 3. Konfirmasi pengembalian
                                              await peminjamanProvider.konfirmasiPengembalian(data.id);

                                              // 4. Refresh items to sync stock
                                              await itemProvider.fetchItems();
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
