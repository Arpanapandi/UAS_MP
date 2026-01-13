import 'package:flutter/material.dart';
import 'dart:ui';

// Model Barang sederhana (Local)
class Barang {
  String id;
  String nama;
  int stok;
  String kategori;

  Barang({required this.id, required this.nama, required this.stok, required this.kategori});
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Barang> _inventory = [
    Barang(id: '1', nama: 'Laptop ASUS ROG', stok: 12, kategori: 'Gaming'),
    Barang(id: '2', nama: 'Monitor Samsung G7', stok: 8, kategori: 'Display'),
    Barang(id: '3', nama: 'Keyboard Mechanical', stok: 45, kategori: 'Peripherals'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addBarang(String nama, int stok, String kategori) {
    setState(() {
      _inventory.add(Barang(
        id: DateTime.now().toString(),
        nama: nama,
        stok: stok,
        kategori: kategori,
      ));
    });
  }

  void _editBarang(String id, String nama, int stok, String kategori) {
    setState(() {
      final index = _inventory.indexWhere((b) => b.id == id);
      if (index != -1) {
        _inventory[index] = Barang(id: id, nama: nama, stok: stok, kategori: kategori);
      }
    });
  }

  void _deleteBarang(String id) {
    setState(() {
      _inventory.removeWhere((b) => b.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(inventory: _inventory),
      ManageBarangPage(
        inventory: _inventory,
        onAdd: _addBarang,
        onEdit: _editBarang,
        onDelete: _deleteBarang,
      ),
      const PlaceholderPage(title: 'Activity', icon: Icons.insights_rounded),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Deep Space Black
      body: Stack(
        children: [
          // Background Glow Effects
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlowSpot(250, const Color(0xFF3B82F6).withOpacity(0.15)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlowSpot(300, const Color(0xFF8B5CF6).withOpacity(0.15)),
          ),
          
          // Main Content with Animated Switcher
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
                BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.rocket_launch_rounded), label: 'Manage'),
                BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Stat'),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF60A5FA),
              unselectedItemColor: Colors.white38,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}

// --- HOME PAGE (GLASS DESIGN) ---
class HomePage extends StatelessWidget {
  final List<Barang> inventory;
  const HomePage({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    int totalStok = inventory.fold(0, (sum, item) => sum + item.stok);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                // Konfigurasi Grid yang meluas ke seluruh layar
                int crossAxisCount;
                double aspectRatio;
                
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                  aspectRatio = 3.5; // Lebih pipih agar pas di layar lebar
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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                  children: [
                    _glassCard('ASSETS', '${inventory.length}', Icons.category_rounded, const Color(0xFF60A5FA)),
                    _glassCard('LIQUIDITY', '$totalStok', Icons.waves_rounded, const Color(0xFF818CF8)),
                    _glassCard('UPTIME', '99.9%', Icons.bolt_rounded, const Color(0xFF34D399)),
                    _glassCard('ALERTS', '2', Icons.emergency_rounded, const Color(0xFFF87171)),
                  ],
                );
              },
            ),
                const SizedBox(height: 32),
                const Text(
                  'Recent Command Centre',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 16),
                _buildGlassAction('System Integrity Check', 'All systems operational', Icons.verified_user_rounded, Colors.greenAccent),
                const SizedBox(height: 12),
                _buildGlassAction('Inventory Syncing...', 'Fetching remote assets', Icons.sync_rounded, Colors.blueAccent),
                const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Commander',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            Text(
              'SIMBA OS Terminal 1.0',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
        _buildGlassIcon(Icons.terminal_rounded),
      ],
    );
  }

  // Widget _buildGlassStatGrid dihapus karena sudah dipindah ke LayoutBuilder di atas agar lebih responsive

  Widget _glassCard(String t, String v, IconData i, Color c) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: c.withOpacity(0.05), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.white.withOpacity(0.04),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        const SizedBox(height: 2),
                        FittedBox(
                          child: Text(v, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.withOpacity(0.2)),
                    ),
                    child: Icon(i, color: c, size: 20),
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildGlassIcon(IconData i) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(i, color: Colors.white, size: 20),
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
                decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(i, color: c, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(s, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
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

// --- MANAGE PAGE (GLOW & GLASS) ---
class ManageBarangPage extends StatelessWidget {
  final List<Barang> inventory;
  final Function(String, int, String) onAdd;
  final Function(String, String, int, String) onEdit;
  final Function(String) onDelete;

  const ManageBarangPage({
    super.key,
    required this.inventory,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  void _showForm(BuildContext context, {Barang? barang}) {
    final namaController = TextEditingController(text: barang?.nama ?? '');
    final stokController = TextEditingController(text: barang?.stok.toString() ?? '');
    final kategoriController = TextEditingController(text: barang?.kategori ?? '');

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
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(barang == null ? 'ADD ASSET' : 'EDIT ASSET', 
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            _modernField(namaController, 'Asset Name'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _modernField(stokController, 'Stock Count', isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _modernField(kategoriController, 'Tier / Category')),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10, shadowColor: const Color(0xFF3B82F6).withOpacity(0.5),
                ),
                onPressed: () {
                  if (barang == null) {
                    onAdd(namaController.text, int.tryParse(stokController.text) ?? 0, kategoriController.text);
                  } else {
                    onEdit(barang.id, namaController.text, int.tryParse(stokController.text) ?? 0, kategoriController.text);
                  }
                  Navigator.pop(context);
                },
                child: const Text('CONFIRM CHANGES', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _modernField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('ASSET MANAGEMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: inventory.isEmpty 
        ? const Center(child: Text('NO ASSETS FOUND', style: TextStyle(color: Colors.white24)))
        : ListView.builder(
            itemCount: inventory.length,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemBuilder: (context, index) {
              final b = inventory[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(b.nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${b.kategori} // SCAN STK: ${b.stok}', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent), onPressed: () => _showForm(context, barang: b)),
                      IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent), onPressed: () => onDelete(b.id)),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: const Color(0xFF3B82F6).withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
