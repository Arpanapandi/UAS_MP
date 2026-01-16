import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../pages/data_barang.dart';
import '../provider/item_provider.dart';
import '../model/Model_data-barang.dart';

import '../pages/data_peminjaman.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ItemProvider>().items; // 🔹 pakai watch supaya rebuild otomatis

    final pages = [
      HomePage(items: items),
      const ManageBarangPage(),
      DataBarang(),
      const HistoryPage(),
    ];

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
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: pages[_selectedIndex],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

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

  Widget _buildGlassBottomNav() {
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.rocket_launch_rounded),
                  label: 'Manage',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: 'Daftar Barang',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: 'Data Peminjaman',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF60A5FA),
              unselectedItemColor: Colors.white38,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= HOME PAGE ================= */
class HomePage extends StatelessWidget {
  final List<Item> items;
  const HomePage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final totalStok = items.fold(0, (sum, i) => sum + i.stok); // 🔹 otomatis update

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                _card('ASSETS', '${items.length}', Icons.category_rounded),
                _card('LIQUIDITY', '$totalStok', Icons.waves_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Welcome, Commander',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Icon(Icons.terminal_rounded, color: Colors.white),
        ],
      );

  Widget _card(String t, String v, IconData i) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.04),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                Text(
                  v,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(i, color: Colors.blueAccent),
        ],
      ),
    );
  }
}

/* ================= MANAGE PAGE ================= */
class ManageBarangPage extends StatelessWidget {
  const ManageBarangPage({super.key});

  void _showForm(BuildContext context, {Item? item}) {
    final namaC = TextEditingController(text: item?.nama ?? '');
    final stokC = TextEditingController(text: item?.stok.toString() ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaC,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: stokC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final provider = context.read<ItemProvider>();
                provider.tambahItem(
                  Item(
                    id: item?.id ?? DateTime.now().toString(),
                    nama: namaC.text,
                    stok: int.tryParse(stokC.text) ?? 0,
                    image: '',
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('SIMPAN'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>(); // 🔹 pakai watch supaya rebuild
    final items = provider.items;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('ASSET MANAGEMENT'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item.nama, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              'Stok: ${item.stok}', // 🔹 otomatis update
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => provider.hapusItem(item.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
