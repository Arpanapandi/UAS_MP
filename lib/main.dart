import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/dashboard.dart';
import 'provider/item_provider.dart';
import 'provider/peminjaman_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => PeminjamanProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinjam Barang Perpustakaan',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Dashboard(),
    );
  }
}
