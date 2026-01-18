import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final String baseUrl = "http://10.0.2.2:8000/api"; // ganti sesuai IP server kamu

  List data = [];

  final namaCtrl = TextEditingController();
  final barangCtrl = TextEditingController();
  final jumlahCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final res = await http.get(Uri.parse("$baseUrl/peminjaman"));
    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
      });
    }
  }

  Future<void> tambahData() async {
    final res = await http.post(
      Uri.parse("$baseUrl/peminjaman"),
      body: {
        "nama_peminjam": namaCtrl.text,
        "nama_barang": barangCtrl.text,
        "jumlah": jumlahCtrl.text,
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      namaCtrl.clear();
      barangCtrl.clear();
      jumlahCtrl.clear();
      Navigator.pop(context);
      getData();
    }
  }

  Future<void> hapusData(id) async {
    await http.delete(Uri.parse("$baseUrl/peminjaman/$id"));
    getData();
  }

  void showForm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Peminjaman"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaCtrl,
              decoration: const InputDecoration(labelText: "Nama Peminjam"),
            ),
            TextField(
              controller: barangCtrl,
              decoration: const InputDecoration(labelText: "Nama Barang"),
            ),
            TextField(
              controller: jumlahCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: tambahData,
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Peminjaman")),
      floatingActionButton: FloatingActionButton(
        onPressed: showForm,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (c, i) {
          final item = data[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text(item['nama_barang']),
              subtitle: Text(
                  "Peminjam: ${item['nama_peminjam']} | Jumlah: ${item['jumlah']}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => hapusData(item['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
