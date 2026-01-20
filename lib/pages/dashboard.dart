import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'login.dart';
import 'data_barang.dart';
import 'data_peminjaman.dart';
import 'manage_barang.dart';

import 'package:provider/provider.dart';
import '../provider/item_provider.dart';
import '../provider/peminjaman_provider.dart';
import '../model/Model_data-barang.dart';

class Dashboard extends StatefulWidget {
  final String? username;
  final String? email;
  final String? password;
  final bool isAdmin;
  
  const Dashboard({
    super.key, 
    this.username, 
    this.email, 
    this.password,
    this.isAdmin = false,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        username: widget.username ?? 'User',
        email: widget.email ?? 'user@example.com',
        isAdmin: widget.isAdmin,
      ),
      ManageBarangPage(isAdmin: widget.isAdmin),
      DataBarang(isAdmin: widget.isAdmin),
      const HistoryPage(), 
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
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Barang'),
                BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Peminjaman'),
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
  final String username;
  final String email;
  final bool isAdmin;
  
  const HomePage({
    super.key, 
    required this.username,
    required this.email,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan Provider untuk data real-time
    final inventory = context.watch<ItemProvider>().items;
    final peminjamanProvider = context.watch<PeminjamanProvider>();
    
    // Hitung statistik real
    int totalStok = inventory.fold(0, (sum, item) => sum + item.stok);
    int activeLoans = peminjamanProvider.listBelumDikembalikan.length;
    int lowStock = inventory.where((item) => item.stok < 3).length; // Alert kalau stok < 3
    
    // Ambil 3 aktivitas terakhir (dibalik urutannya biar yang baru diatas)
    final recentActivities = peminjamanProvider.listPeminjaman.reversed.take(3).toList();

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
                  crossAxisSpacing: 8, 
                  mainAxisSpacing: 8,
                  childAspectRatio: aspectRatio,
                  children: [
                    _glassCard('ASSETS', '${inventory.length}', Icons.category_rounded, const Color(0xFF60A5FA)),
                    _glassCard('LIQUIDITY', '$totalStok', Icons.waves_rounded, const Color(0xFF818CF8)),
                    _glassCard('ON LOAN', '$activeLoans', Icons.access_time_filled_rounded, const Color(0xFF34D399)),
                    _glassCard('LOW STOCK', '$lowStock', Icons.warning_rounded, lowStock > 0 ? const Color(0xFFF87171) : Colors.greenAccent),
                  ],
                );
              },
            ),
                const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Recent Activity Log',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              
              if (recentActivities.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildGlassAction(
                    'System Standby', 
                    'No recent transactions recorded', 
                    Icons.history_toggle_off_rounded, 
                    Colors.white24
                  ),
                )
              else
                ...recentActivities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                  child: _buildGlassAction(
                    activity.sudahDikembalikan ? 'Item Returned' : 'Item Borrowed', 
                    '${activity.namaBarang} (${activity.jumlah} unit)', 
                    activity.sudahDikembalikan ? Icons.assignment_return_rounded : Icons.outbox_rounded, 
                    activity.sudahDikembalikan ? Colors.greenAccent : Colors.orangeAccent
                  ),
                )),
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
                    Text(
                      isAdmin ? 'Good Evening, Commander' : 'Welcome, Cadet',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: isAdmin ? Colors.redAccent : const Color(0xFF34D399), size: 8),
                          const SizedBox(width: 6),
                          Text(
                            isAdmin ? 'ADMIN ACCESS' : 'ONLINE',
                            style: TextStyle(
                              color: isAdmin ? Colors.redAccent : Colors.white, 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1
                            ),
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
                                fontSize: 32, 
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
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent.withOpacity(0.2),
                                        foregroundColor: Colors.redAccent,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      icon: const Icon(Icons.logout),
                                      label: const Text('LOGOUT SYSTEM'),
                                      onPressed: () {
                                        Navigator.pop(ctx); 
                                        Navigator.pushReplacement(
                                          context, 
                                          MaterialPageRoute(builder: (context) => const LoginPage()),
                                        );
                                      },
                                    ),
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



