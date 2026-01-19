import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login.dart';
import 'provider/item_provider.dart';
import 'provider/peminjaman_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => PeminjamanProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SIMBA Dashboard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
          useMaterial3: true,
        ),
        home: LoginPage(),
      ),
    );
  }
}