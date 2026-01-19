import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final String baseUrl = "http://10.0.2.2:8000/api";

  List data = [];
  List filtered = [];
  bool isLoading = true;

  final namaCtrl = TextEditingController();
  final barangCtrl = TextEditingController();
  final jumlahCtrl = TextEditingController();

  String? editId;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() => isLoading = true);
    final res = await http.get(Uri.parse("$baseUrl/peminjaman"));

    if (res.statusCode == 200) {
      data = json.decode(res.body);
      filtered = data;
    }

    setState(() => isLoading = false);
  }

  Future<void> simpanData() async {
    if (namaCtrl.text.isEmpty ||
        barangCtrl.text.isEmpty ||
        jumlahCtrl.text.isEmpty) return;

    http.Response res;

    if (editId == null) {
      // CREATE
      res = await http.post(
        Uri.parse("$baseUrl/peminjaman"),
        headers: {"Accept": "application/json"},
        body: {
          "nama_peminjam": namaCtrl.text,
          "nama_barang": barangCtrl.text,
          "jumlah": jumlahCtrl.text,
        },
      );
    } else {
      // UPDATE
      res = await http.put(
        Uri.parse("$baseUrl/peminjaman/$editId"),
        headers: {"Accept": "application/json"},
        body: {
          "nama_peminjam": namaCtrl.text,
          "nama_barang": barangCtrl.text,
          "jumlah": jumlahCtrl.text,
        },
      );
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.pop(context);
      resetForm();
      getData();
    }
  }

  Future<void> hapusData(id) async {
    await http.delete(Uri.parse("$baseUrl/peminjaman/$id"));
    getData();
  }

  void search(String q) {
    setState(() {
      filtered = data
          .where((e) =>
              e['nama_barang'].toLowerCase().contains(q.toLowerCase()) ||
              e['nama_peminjam'].toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  void showForm({item}) {
    if (item != null) {
      editId = item['id'].toString();
      namaCtrl.text = item['nama_peminjam'];
      barangCtrl.text = item['nama_barang'];
      jumlahCtrl.text = item['jumlah'].toString();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF020617),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          editId == null ? "Tambah Peminjaman" : "Edit Peminjaman",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(namaCtrl, "Nama Peminjam"),
            _input(barangCtrl, "Nama Barang"),
            _input(jumlahCtrl, "Jumlah", number: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetForm();
            },
            child: const Text("Batal", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: simpanData,
            child: Text(editId == null ? "Simpan" : "Update"),
          ),
        ],
      ),
    );
  }

  void resetForm() {
    editId = null;
    namaCtrl.clear();
    barangCtrl.clear();
    jumlahCtrl.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0B132B), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Data Peminjaman",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _totalCard(),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari peminjam / barang...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? const Center(
                            child: Text("Data kosong",
                                style: TextStyle(color: Colors.white54)),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (c, i) {
                              final item = filtered[i];

                              return Dismissible(
                                key: ValueKey(item['id']),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) => hapusData(item['id']),
                                child: GestureDetector(
                                  onTap: () => showForm(item: item),
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.05),
                                          Colors.white.withOpacity(0.01),
                                        ],
                                      ),
                                      border:
                                          Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['nama_barang'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(
                                            "Peminjam: ${item['nama_peminjam']}",
                                            style: const TextStyle(
                                                color: Colors.white54)),
                                        Text("Jumlah: ${item['jumlah']}",
                                            style: const TextStyle(
                                                color: Colors.white54)),
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
      ),
    );
  }

  Widget _totalCard() {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment, color: Colors.blueAccent, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Peminjaman",
                  style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 4),
              Text(
                filtered.length.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
