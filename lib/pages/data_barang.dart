import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../model/barang.dart';
import '../services/barang_services.dart';
import '../services/auth_services.dart';
import '../services/peminjaman_services.dart';

class DataBarangPage extends StatefulWidget {
  const DataBarangPage({super.key});

  @override
  State<DataBarangPage> createState() => _DataBarangPageState();
}

class _DataBarangPageState extends State<DataBarangPage> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BarangServices>(context, listen: false).fetchBarang();
    });
  }

  @override
  Widget build(BuildContext context) {
    final barangServices = Provider.of<BarangServices>(context);
    final user = Provider.of<AuthServices>(context).currentUser;
    final isAdmin = user?.role == 'admin';

    List<Barang> filteredList = barangServices.barangList.where((item) {
      return item.namaBarang.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Barang'),
        centerTitle: true,
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        backgroundColor: const Color(0xFF06B6D4),
        child: const Icon(LucideIcons.plus, color: Colors.white),
        onPressed: () => _showBarangDialog(context),
      ) : null,
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: barangServices.isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
                : _buildBarangList(filteredList, isAdmin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search Items...',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(LucideIcons.search, color: Color(0xFF06B6D4)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF06B6D4)),
        ),
      ),
    );
  }

  Widget _buildBarangList(List<Barang> items, bool isAdmin) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No items found',
          style: GoogleFonts.poppins(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ]
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                image: item.imageUrl != null 
                  ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                  : null,
              ),
              child: item.imageUrl == null 
                ? const Icon(LucideIcons.image, color: Colors.white24) 
                : null,
            ),
            title: Text(
              item.namaBarang,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Stock: ${item.stok}',
                  style: GoogleFonts.poppins(
                    color: item.stok > 0 ? const Color(0xFF4ADE80) : Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.deskripsi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            trailing: isAdmin 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.edit2, color: Colors.blueAccent),
                      onPressed: () => _showBarangDialog(context, barang: item),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(context, item.id),
                    ),
                  ],
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: item.stok > 0 ? () => _pinjamBarang(context, item) : null,
                  child: const Text('Pinjam'),
                ),
          ),
        );
      },
    );
  }

  void _pinjamBarang(BuildContext context, Barang item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Pinjam ${item.namaBarang}?', style: GoogleFonts.orbitron(color: Colors.white)),
        content: Text('Are you sure you want to borrow this item?', style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () async {
              // Get current date
              final now = DateTime.now().toIso8601String().split('T')[0];
              final success = await Provider.of<PeminjamanServices>(context, listen: false)
                  .pinjamBarang(item.id, now);
              
              if (mounted) {
                 Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil meminjam barang')),
                  );
                  // Refresh stock
                  Provider.of<BarangServices>(context, listen: false).fetchBarang();
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal meminjam barang')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Item', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await Provider.of<BarangServices>(context, listen: false).deleteBarang(id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showBarangDialog(BuildContext context, {Barang? barang}) {
    final isEdit = barang != null;
    final nameController = TextEditingController(text: barang?.namaBarang);
    final stockController = TextEditingController(text: barang?.stok.toString());
    final descController = TextEditingController(text: barang?.deskripsi);
    final codeController = TextEditingController(text: barang?.kodeBarang);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(isEdit ? 'Edit Barang' : 'Add Barang', style: GoogleFonts.orbitron(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogInput(codeController, 'Kode Barang'),
              const SizedBox(height: 10),
              _buildDialogInput(nameController, 'Nama Barang'),
              const SizedBox(height: 10),
              _buildDialogInput(stockController, 'Stok', isNumber: true),
              const SizedBox(height: 10),
              _buildDialogInput(descController, 'Deskripsi'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final newBarang = Barang(
                id: isEdit ? barang.id : 0,
                kodeBarang: codeController.text,
                namaBarang: nameController.text,
                stok: int.tryParse(stockController.text) ?? 0,
                deskripsi: descController.text,
                imageUrl: barang?.imageUrl, // Keep existing image or null
              );

              final service = Provider.of<BarangServices>(context, listen: false);
              bool success;
              if (isEdit) {
                success = await service.updateBarang(barang.id, newBarang);
              } else {
                success = await service.addBarang(newBarang);
              }

              if (context.mounted) {
                Navigator.pop(context);
                 if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Success ${isEdit ? 'Updated' : 'Added'}')),
                  );
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInput(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
      ),
    );
  }
}
