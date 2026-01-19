import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../pages/data_barang.dart';
import '../provider/item_provider.dart';
import '../model/Model_data-barang.dart';

import '../pages/data_peminjaman.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required String username});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ItemProvider>().items;

    final pages = [
      HomePage(
        inventory: items.map((e) => Barang(id: e.id, nama: e.nama, stok: e.stok, kategori: "Unknown")).toList(),
        username: "Commander",
        email: "commander@simba.id",
      ),
      const ManageBarangPage(),
      DataBarang(),
      HistoryPage(),
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
                  icon: Icon(Icons.history),
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

/* ================= HOME PAGE (MERGE DARI KODE BARU) ================= */

class Barang {
  String id;
  String nama;
  int stok;
  String kategori;

  Barang({
    required this.id,
    required this.nama,
    required this.stok,
    required this.kategori,
  });
}

class HomePage extends StatelessWidget {
  final List<Barang> inventory;
  final String username;
  final String email;

  const HomePage({
    super.key,
    required this.inventory,
    required this.username,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    int totalStok = inventory.fold(0, (sum, item) => sum + item.stok);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, username, email),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                double aspectRatio;

                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                  aspectRatio = 3.5;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 4;
                  aspectRatio = 2.5;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 2;
                  aspectRatio = 3.0;
                } else {
                  crossAxisCount = 2;
                  aspectRatio = 2.2;
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: aspectRatio,
                  children: [
                    _glassCard('ASSETS', '${inventory.length}', Icons.category_rounded,
                        const Color(0xFF60A5FA)),
                    _glassCard('LIQUIDITY', '$totalStok', Icons.waves_rounded,
                        const Color(0xFF818CF8)),
                    _glassCard('UPTIME', '99.9%', Icons.bolt_rounded,
                        const Color(0xFF34D399)),
                    _glassCard('ALERTS', '2', Icons.emergency_rounded,
                        const Color(0xFFF87171)),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Recent Command Centre',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildGlassAction('System Integrity Check', 'All systems operational',
                  Icons.verified_user_rounded, Colors.greenAccent),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildGlassAction(
                  'Inventory Syncing...', 'Fetching remote assets', Icons.sync_rounded, Colors.blueAccent),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String username, String email) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF020617), Color(0xFF2563EB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            bottom: -50,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  center: Alignment.center,
                  radius: 0.7,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Good Evening, Commander',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF34D399), size: 8),
                          SizedBox(width: 6),
                          Text(
                            'ONLINE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  username,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final now = DateTime.now();
                        final hour = now.hour.toString().padLeft(2, '0');
                        final minute = now.minute.toString().padLeft(2, '0');
                        final second = now.second.toString().padLeft(2, '0');

                        final List<String> months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ];
                        final dateString =
                            '${now.day} ${months[now.month - 1]} ${now.year}';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$hour:$minute',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2),
                            ),
                            Text(
                              dateString,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1),
                            ),
                          ],
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 20)
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Color(0xFF2563EB),
                                    child: Icon(Icons.person,
                                        size: 40, color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(username,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  Text(email,
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 14)),
                                  const SizedBox(height: 24),
                                  const Divider(color: Colors.white10),
                                  ListTile(
                                    leading: const Icon(Icons.badge,
                                        color: Colors.blueAccent),
                                    title: const Text('Role',
                                        style: TextStyle(color: Colors.white)),
                                    subtitle: const Text('Super Administrator',
                                        style: TextStyle(
                                            color: Colors.white54)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 10)
                          ],
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Color(0xFF2563EB), size: 28),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard(String t, String v, IconData i, Color c) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final isVerySmall = cardWidth < 120;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                  color: c.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: -5),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: EdgeInsets.all(isVerySmall ? 6 : 8),
                color: Colors.white.withOpacity(0.04),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              t,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: isVerySmall ? 7 : 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              v,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isVerySmall ? 16 : 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.all(isVerySmall ? 4 : 6),
                      decoration: BoxDecoration(
                        color: c.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: c.withOpacity(0.2)),
                      ),
                      child: Icon(i, color: c, size: isVerySmall ? 14 : 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassAction(String t, String s, IconData i, Color c) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration:
                    BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(i, color: c, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(s,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_right_alt_rounded, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= MANAGE PAGE (MERGE DARI KODE BARU) ================= */

class ManageBarangPage extends StatelessWidget {
  const ManageBarangPage({super.key});

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
      body: items.isEmpty
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
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(b.nama,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${b.kategori} // SCAN STK: ${b.stok}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded,
                              color: Colors.blueAccent),
                          onPressed: () => _showForm(context, provider, item: b),
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
                    child: _modernField(kategoriController, 'Tier / Category')),
              ],
            ),
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
                onPressed: () {
                  if (item == null) {
                    provider.tambahItem(Item(
                      id: DateTime.now().toString(),
                      nama: namaController.text,
                      stok: int.tryParse(stokController.text) ?? 0,
                      kategori: kategoriController.text,
                      image: '',
                    ));
                  } else {
                    provider.ubahItem(Item(
                      id: item.id,
                      nama: namaController.text,
                      stok: int.tryParse(stokController.text) ?? 0,
                      kategori: kategoriController.text,
                      image: '',
                    ));
                  }
                  Navigator.pop(context);
                },
                child: const Text('CONFIRM CHANGES',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _modernField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
