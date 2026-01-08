import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('TOTAL BARANG', '150', Colors.blue),
                _buildStatCard('DIPINJAM', '12', Colors.orange),
                _buildStatCard('TERSEDIA', '38', Colors.green),
                _buildStatCard('TELAT', '38', Colors.green),
              ],
            )
            // Add more widgets here as needed
          ],
        ),
      ),
    );
  }
}

_buildStatCard(String s, String t, MaterialColor blue) {
}