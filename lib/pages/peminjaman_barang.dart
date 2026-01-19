import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/peminjaman_services.dart';
import '../services/auth_services.dart';

class PeminjamanBarangPage extends StatefulWidget {
  const PeminjamanBarangPage({super.key});

  @override
  State<PeminjamanBarangPage> createState() => _PeminjamanBarangPageState();
}

class _PeminjamanBarangPageState extends State<PeminjamanBarangPage> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PeminjamanServices>(context, listen: false).fetchPeminjaman();
    });
  }

  @override
  Widget build(BuildContext context) {
    final peminjamanServices = Provider.of<PeminjamanServices>(context);
    // User context might be useful if we want to filter locally, but API usually handles it.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Peminjaman'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: peminjamanServices.isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
          : peminjamanServices.peminjamanList.isEmpty 
              ? Center(child: Text("No Loan History", style: GoogleFonts.poppins(color: Colors.white54)))
              : ListView.builder(
                  itemCount: peminjamanServices.peminjamanList.length,
                  itemBuilder: (context, index) {
                    final loan = peminjamanServices.peminjamanList[index];
                    final isDipinjam = loan.status.toLowerCase() == 'dipinjam';
                    
                    return Card(
                      color: Colors.white.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDipinjam 
                            ? Colors.yellowAccent.withOpacity(0.3) 
                            : const Color(0xFF4ADE80).withOpacity(0.3)
                        )
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loan.namaBarang ?? 'Unknown Item',
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDipinjam 
                                      ? Colors.yellow.withOpacity(0.2) 
                                      : Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDipinjam ? Colors.yellow : Colors.green
                                    )
                                  ),
                                  child: Text(
                                    loan.status,
                                    style: GoogleFonts.poppins(
                                      color: isDipinjam ? Colors.yellow : Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(LucideIcons.calendar, size: 14, color: Colors.white54),
                                const SizedBox(width: 6),
                                Text(
                                  'Pinjam: ${loan.tanggalPinjam}',
                                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                             if (loan.tanggalKembali != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.checkCircle, size: 14, color: Colors.white54),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Kembali: ${loan.tanggalKembali}',
                                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            if (isDipinjam) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF06B6D4),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final success = await Provider.of<PeminjamanServices>(context, listen: false)
                                        .kembalikanBarang(loan.id);
                                    if (context.mounted) {
                                      if (success) {
                                         ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Item Returned Successfully')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Failed to Return Item')),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('KEMBALIKAN'),
                                ),
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
