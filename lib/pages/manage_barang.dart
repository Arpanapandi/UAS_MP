import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../provider/item_provider.dart';
import '../model/Model_data-barang.dart';

class ManageBarangPage extends StatefulWidget {
  final bool isAdmin;
  const ManageBarangPage({super.key, this.isAdmin = false});

  @override
  State<ManageBarangPage> createState() => _ManageBarangPageState();
}

class _ManageBarangPageState extends State<ManageBarangPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemProvider>(context, listen: false).fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final items = provider.items;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'ASSET MANAGEMENT',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(
                  child: Text('NO ASSETS FOUND',
                      style: TextStyle(color: Colors.white24)),
                )
              : ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemBuilder: (context, index) {
                    final b = items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: ListTile(
                        leading: b.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  b.image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade800,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: Colors.white54,
                                ),
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        title: Text(b.nama,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${b.kategori} // SCAN STK: ${b.stok}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded,
                                  color: Colors.blueAccent),
                              onPressed: () =>
                                  _showForm(context, provider, item: b),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_rounded,
                                  color: Colors.redAccent),
                              onPressed: () => provider.hapusItem(b.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, provider),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  void _showForm(BuildContext context, ItemProvider provider, {Item? item}) {
    final namaController = TextEditingController(text: item?.nama ?? '');
    final stokController =
        TextEditingController(text: item?.stok.toString() ?? '');
    final kategoriController =
        TextEditingController(text: item?.kategori ?? '');
    final imageController = TextEditingController(text: item?.image ?? '');
    final keteranganController = TextEditingController(text: item?.keterangan ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item == null ? 'ADD ASSET' : 'EDIT ASSET',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              _modernField(namaController, 'Asset Name'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _modernField(stokController, 'Stock Count',
                          isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _modernField(kategoriController, 'Category')),
                ],
              ),
              const SizedBox(height: 16),
              _modernField(imageController, 'Image URL (optional)'),
              const SizedBox(height: 16),
              _modernField(keteranganController, 'Description', maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: const Color(0xFF3B82F6).withOpacity(0.5),
                  ),
                  onPressed: () async {
                    if (item == null) {
                      await provider.tambahItem(Item(
                        id: "0",
                        nama: namaController.text,
                        stok: int.tryParse(stokController.text) ?? 0,
                        kategori: kategoriController.text,
                        image: imageController.text,
                        keterangan: keteranganController.text,
                      ));
                    } else {
                      await provider.ubahItem(Item(
                        id: item.id,
                        nama: namaController.text,
                        stok: int.tryParse(stokController.text) ?? 0,
                        kategori: kategoriController.text,
                        image: imageController.text,
                        keterangan: keteranganController.text,
                      ));
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('CONFIRM CHANGES',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernField(TextEditingController controller, String hint,
      {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      ),
    );
  }
}
