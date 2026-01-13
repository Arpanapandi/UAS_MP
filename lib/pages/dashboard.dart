import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Catatan: Saat digabung ke project utama, 
// ganti placeholder di bawah dengan import file asli milik teman kamu.

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  // Daftar halaman: HomePage milik kamu, sisanya placeholder
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    PlaceholderPage(title: 'Data Barang', icon: Icons.inventory_2_rounded),
    PlaceholderPage(title: 'Peminjaman', icon: Icons.assignment_rounded),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_rounded),
                label: 'Barang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_rounded),
                label: 'Pinjam',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF3B82F6),
            unselectedItemColor: Colors.grey.shade400,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

// --- BAGIAN MILIK KAMU (HOME PAGE) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistik Hari Ini',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Total Barang', '120', Icons.inventory, Colors.blue),
                    _buildStatCard('Dipinjam', '15', Icons.outbound, Colors.orange),
                    _buildStatCard('Tersedia', '105', Icons.check_circle, Colors.green),
                    _buildStatCard('Terlambat', '3', Icons.warning_rounded, Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Aksi Cepat',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
                _buildQuickAction(context, 'Cari Barang', 'Temukan inventaris dengan mudah', Icons.search_rounded, Colors.blue),
                const SizedBox(height: 12),
                _buildQuickAction(context, 'Scan QR Code', 'Scan untuk melihat detail barang', Icons.qr_code_scanner_rounded, Colors.purple),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, Admin!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Selamat datang di SIMBA', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8))),
            ],
          ),
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

// --- WIDGET PLACEHOLDER (Hanya untuk testing biar tidak error) ---
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Halaman $title Bakal Muncul Di Sini',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '(Ini adalah placeholder sementara)',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
