import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/data_barang.dart';
import 'pages/dashboard.dart';
import 'provider/item_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ItemProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinjam Barang Perpustakaan',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Dashboard(),
    );
  }
}
