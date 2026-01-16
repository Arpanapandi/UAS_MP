import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'login.dart';
// import 'login.dart';

// Model Barang sederhana (Local)
class Barang {
  String id;
  String nama;
  int stok;
  String kategori;

  Barang({required this.id, required this.nama, required this.stok, required this.kategori});
}

class Dashboard extends StatefulWidget {
  final String? username;  // Nama user dari login (opsional)
  final String? email;     // Email user dari login (opsional)
  final String? password;  // Password (tidak ditampilkan, hanya untuk kompatibilitas)
  
  const Dashboard({super.key, this.username, this.email, this.password});

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
      HomePage(
        inventory: _inventory,
        username: widget.username ?? 'John Doe',
        email: widget.email ?? 'commander.john@simba.id',
      ),
      DaftarBarangPage(inventory: _inventory),
      ManageBarangPage(
        inventory: _inventory,
        onAdd: _addBarang,
        onEdit: _editBarang,
        onDelete: _deleteBarang,
      ),
      const PlaceholderPage(title: 'Peminjaman', icon: Icons.assignment_rounded),
      const PlaceholderPage(title: 'Pengembalian', icon: Icons.assignment_return_rounded),
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
                BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Daftar'),
                BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: 'Kelola'),
                BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Pinjam'),
                BottomNavigationBarItem(icon: Icon(Icons.assignment_return_rounded), label: 'Kembali'),
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
        padding: const EdgeInsets.only(top: 20, bottom: 20), // Hilangkan padding kiri-kanan
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, username, email),
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
                  crossAxisSpacing: 8, // Kurangi jarak antar kartu
                  mainAxisSpacing: 8,
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Recent Command Centre',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildGlassAction('System Integrity Check', 'All systems operational', Icons.verified_user_rounded, Colors.greenAccent),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildGlassAction('Inventory Syncing...', 'Fetching remote assets', Icons.sync_rounded, Colors.blueAccent),
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
      // height: 240, // Hapus fixed height biar gak overflow (garis kuning hitam)
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
            padding: const EdgeInsets.all(24.0), // Padding dikurangi biar lebih compact
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Good Evening, Commander',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    // Status Badge dipindah ke kanan atas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  username,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                
                const SizedBox(height: 32), // Jarak ke bawah
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Real-time Clock using StreamBuilder
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final now = DateTime.now();
                        final hour = now.hour.toString().padLeft(2, '0');
                        final minute = now.minute.toString().padLeft(2, '0');
                        final second = now.second.toString().padLeft(2, '0');
                        
                        // Manual Date Formatting to avoid intl dependency
                        final List<String> months = [
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ];
                        final dateString = '${now.day} ${months[now.month - 1]} ${now.year}';
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$hour:$minute',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 32, // Lebih Besar
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              dateString,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8), 
                                fontSize: 14, 
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
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
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 20)],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Color(0xFF2563EB),
                                    child: Icon(Icons.person, size: 40, color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(username, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                  Text(email, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                                  const SizedBox(height: 24),
                                  const Divider(color: Colors.white10),
                                  ListTile(
                                    leading: const Icon(Icons.badge, color: Colors.blueAccent),
                                    title: const Text('Role', style: TextStyle(color: Colors.white)),
                                    subtitle: const Text('Super Administrator', style: TextStyle(color: Colors.white54)),
                                  ),
                                  // const SizedBox(height: 20),
                                  // SizedBox(
                                  //   width: double.infinity,
                                  //   child: ElevatedButton.icon(
                                  //     style: ElevatedButton.styleFrom(
                                  //       backgroundColor: Colors.redAccent.withOpacity(0.2),
                                  //       foregroundColor: Colors.redAccent,
                                  //       padding: const EdgeInsets.symmetric(vertical: 16),
                                  //     ),
                                  //     icon: const Icon(Icons.logout),
                                  //     label: const Text('LOGOUT SYSTEM'),
                                  //     onPressed: () {
                                  //       Navigator.pop(ctx); // Tutup dialog
                                  //       Navigator.pushReplacement(
                                  //         context, 
                                  //         MaterialPageRoute(builder: (context) => const LoginPage()),
                                  //       );
                                  //     },
                                  //   ),
                                  // ),
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
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 28),
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

  // Widget _buildGlassStatGrid dihapus karena sudah dipindah ke LayoutBuilder di atas agar lebih responsive

  Widget _glassCard(String t, String v, IconData i, Color c) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung ukuran dinamis berdasarkan lebar kartu
        final cardWidth = constraints.maxWidth;
        final isVerySmall = cardWidth < 120;
        
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

// --- DAFTAR BARANG PAGE ---
class DaftarBarangPage extends StatelessWidget {
  final List<Barang> inventory;
  const DaftarBarangPage({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF60A5FA), size: 28),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Barang',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Inventaris Lengkap',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // List Barang
          Expanded(
            child: inventory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 80, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada barang',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      final barang = inventory[index];
                      return _buildBarangCard(barang, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangCard(Barang barang, int index) {
    // Warna gradient berdasarkan index
    final colors = [
      [const Color(0xFF60A5FA), const Color(0xFF818CF8)],
      [const Color(0xFF34D399), const Color(0xFF10B981)],
      [const Color(0xFFF59E0B), const Color(0xFFF97316)],
      [const Color(0xFFEC4899), const Color(0xFFEF4444)],
    ];
    final colorPair = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [colorPair[0].withOpacity(0.1), colorPair[1].withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorPair[0], colorPair[1]],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorPair[0].withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.category_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang.nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(Icons.inventory, 'Stok: ${barang.stok}', colorPair[0]),
                          const SizedBox(width: 12),
                          _buildInfoChip(Icons.tag, 'ID: ${barang.id}', colorPair[1]),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Stock Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: barang.stok > 10 
                        ? const Color(0xFF34D399).withOpacity(0.2)
                        : const Color(0xFFF87171).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: barang.stok > 10 
                          ? const Color(0xFF34D399)
                          : const Color(0xFFF87171),
                    ),
                  ),
                  child: Text(
                    barang.stok > 10 ? 'Tersedia' : 'Terbatas',
                    style: TextStyle(
                      color: barang.stok > 10 
                          ? const Color(0xFF34D399)
                          : const Color(0xFFF87171),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
          ),
        ],
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
