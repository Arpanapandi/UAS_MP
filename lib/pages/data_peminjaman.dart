import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/peminjaman_provider.dart';
import '../provider/item_provider.dart';
import '../model/Model_data-peminjaman.dart';

class DataPeminjamanPage extends StatefulWidget {
  const DataPeminjamanPage({super.key});

  @override
  State<DataPeminjamanPage> createState() => _DataPeminjamanPageState();
}

class _DataPeminjamanPageState extends State<DataPeminjamanPage> {
  String search = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PeminjamanProvider>().getData();
      context.read<ItemProvider>().getData();
    });
  }

  void showForm(BuildContext context, {DataPeminjaman? item}) {
    final pem = context.read<PeminjamanProvider>();
    final barang = context.read<ItemProvider>();

    if (item != null) {
      pem.setEdit(item);
    } else {
      pem.resetForm();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF020617),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          item == null ? "Tambah Peminjaman" : "Edit Peminjaman",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(pem.namaCtrl, "Nama Peminjam"),
            _dropdownBarang(barang, pem),
            _input(pem.jumlahCtrl, "Jumlah", number: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pem.resetForm();
            },
            child: const Text("Batal", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              await pem.simpan();
              Navigator.pop(context);
            },
            child: Text(item == null ? "Simpan" : "Update"),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdownBarang(ItemProvider barang, PeminjamanProvider pem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          dropdownColor: const Color(0xFF020617),
          isExpanded: true,
          value: pem.selectedBarangId,
          hint: const Text("Pilih Barang", style: TextStyle(color: Colors.white54)),
          items: barang.items
              .map(
                (e) => DropdownMenuItem<int>(
                  value: e.id,
                  child: Text(e.namaBarang,
                      style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: (v) => pem.setBarang(v),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pem = context.watch<PeminjamanProvider>();

    final list = pem.items.where((e) {
      final q = search.toLowerCase();
      return e.namaBarang.toLowerCase().contains(q) ||
          e.namaPeminjam.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => showForm(context),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          _glow(top: -100, right: -100, color: Colors.blueAccent),
          _glow(bottom: -80, left: -80, color: Colors.purpleAccent),

          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Data Peminjaman",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // TOTAL
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _totalCard(list.length),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (v) => setState(() => search = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari peminjam / barang...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: pem.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : list.isEmpty
                          ? const Center(child: Text("Data kosong", style: TextStyle(color: Colors.white54)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: list.length,
                              itemBuilder: (c, i) {
                                final item = list[i];

                                return Dismissible(
                                  key: ValueKey(item.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.only(right: 20),
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  onDismissed: (_) => pem.hapus(item.id),
                                  child: GestureDetector(
                                    onTap: () => showForm(context, item: item),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: Colors.white.withOpacity(0.05),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.namaBarang,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Text("Peminjam: ${item.namaPeminjam}",
                                              style: const TextStyle(color: Colors.white54)),
                                          Text("Jumlah: ${item.jumlah}",
                                              style: const TextStyle(color: Colors.white54)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow({double? top, double? bottom, double? left, double? right, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 120, spreadRadius: 40)],
        ),
      ),
    );
  }

  Widget _totalCard(int total) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment, color: Colors.blueAccent, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Peminjaman", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 4),
              Text(
                total.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
