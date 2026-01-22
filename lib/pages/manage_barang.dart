import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
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

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
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
      body: provider.isLoading && items.isEmpty
          ? _buildShimmerLoading()
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
                                child: kIsWeb 
                                  ? SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Builder(
                                          builder: (context) {
                                            final String viewId = 'manage-img-${b.id}';
                                            // ignore: undefined_prefixed_name
                                            ui.platformViewRegistry.registerViewFactory(
                                              viewId,
                                              (int id) => html.ImageElement()
                                                ..src = "${b.image}?v=${DateTime.now().millisecondsSinceEpoch}"
                                                ..style.width = '100%'
                                                ..style.height = '100%'
                                                ..style.objectFit = 'cover',
                                            );
                                            return HtmlElementView(viewType: viewId);
                                          },
                                        ),
                                    )
                                  : Image.network(
                                      "${b.image}?v=${DateTime.now().millisecondsSinceEpoch}",
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
    final keteranganController =
        TextEditingController(text: item?.keterangan ?? '');
    
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          
          Future<void> pickImage() async {
            final XFile? returnedImage =
                await picker.pickImage(source: ImageSource.gallery);
            if (returnedImage != null) {
              setStateBottomSheet(() {
                selectedImage = returnedImage;
              });
            }
          }

          return Container(
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
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item == null ? 'ADD ASSET' : 'EDIT ASSET',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                         icon: const Icon(Icons.close, color: Colors.white54)
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            style: BorderStyle.solid),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: kIsWeb
                                ? Image.network(
                                    selectedImage!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : const Center(child: Text("Mobile Preview Not Supported without dart:io", style: TextStyle(color: Colors.white))),
                            )
                          : (item != null && item.image.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: kIsWeb
                                    ? Builder(
                                        builder: (context) {
                                          final String viewId = 'preview-img-${item.id}';
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
                                    : Image.network(
                                        "${item.image}?v=${DateTime.now().millisecondsSinceEpoch}",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) => const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image,
                                                color: Colors.white54, size: 40),
                                            SizedBox(height: 8),
                                            Text("Image Load Failed",
                                                style:
                                                    TextStyle(color: Colors.white54)),
                                          ],
                                        ),
                                      ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_rounded,
                                        color: Colors.blueAccent, size: 40),
                                    SizedBox(height: 8),
                                    Text("Tap to upload image",
                                        style: TextStyle(color: Colors.blueAccent)),
                                  ],
                                ),
                    ),
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
                        // Simple validation
                        if (namaController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Name is required')),
                          );
                          return;
                        }

                        try {
                          if (item == null) {
                            await provider.tambahItem(
                              Item(
                                id: "0",
                                nama: namaController.text,
                                stok: int.tryParse(stokController.text) ?? 0,
                                kategori: kategoriController.text,
                                image: "", 
                                keterangan: keteranganController.text,
                              ),
                              imageFile: selectedImage
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Item added successfully!'), backgroundColor: Colors.green),
                              );
                            }
                          } else {
                            await provider.ubahItem(
                              Item(
                                id: item.id,
                                nama: namaController.text,
                                stok: int.tryParse(stokController.text) ?? 0,
                                kategori: kategoriController.text,
                                image: item.image, 
                                keterangan: keteranganController.text,
                              ),
                              imageFile: selectedImage
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Item updated successfully!'), backgroundColor: Colors.green),
                              );
                            }
                          }
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: const Text('CONFIRM CHANGES',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          );
        }
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
