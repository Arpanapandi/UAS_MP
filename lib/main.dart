import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';
import 'pages/data_barang.dart';
import 'pages/peminjaman_barang.dart';
import 'services/auth_services.dart';
import 'services/barang_services.dart';
import 'services/peminjaman_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthServices()),
        ChangeNotifierProvider(create: (_) => BarangServices()),
        ChangeNotifierProvider(create: (_) => PeminjamanServices()),
      ],
      child: MaterialApp(
        title: 'Sistem Peminjaman Kampus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Midnight Blue
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF06B6D4), // Neon Cyan
            primary: const Color(0xFF06B6D4),
            secondary: const Color(0xFF8B5CF6), // Electric Purple
            surface: const Color(0xFF1E293B), // Slightly lighter blue/slate
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/data_barang': (context) => const DataBarangPage(),
          '/peminjaman_barang': (context) => const PeminjamanBarangPage(),
        },
      ),
    );
  }
}
