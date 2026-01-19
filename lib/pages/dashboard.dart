import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/auth_services.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthServices>(context).currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          user?.name ?? 'Student',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.logOut, color: Colors.redAccent),
                      onPressed: () {
                         Provider.of<AuthServices>(context, listen: false).logout();
                         Navigator.pushReplacementNamed(context, '/login');
                      },
                    )
                  ],
                ),
                const SizedBox(height: 30),
                _buildStatsGrid(),
                const SizedBox(height: 30),
                Text(
                  'Quick Menu',
                  style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        context,
                        'Data Barang',
                        LucideIcons.box,
                        const Color(0xFF06B6D4),
                        '/data_barang',
                      ),
                      _buildMenuCard(
                        context,
                        'Peminjaman',
                        LucideIcons.history,
                        const Color(0xFF8B5CF6),
                        '/peminjaman_barang',
                      ),
                      _buildMenuCard(
                         context, 
                         'Profile', 
                         LucideIcons.user, 
                         Colors.pinkAccent, 
                         null // Placeholder
                      ),
                       _buildMenuCard(
                         context, 
                         'Help', 
                         LucideIcons.helpCircle, 
                         Colors.orangeAccent, 
                         null // Placeholder
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Active Loans', '3', const Color(0xFF06B6D4)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Items Available', '124', const Color(0xFF8B5CF6)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
         boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String? route) {
    return InkWell(
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
