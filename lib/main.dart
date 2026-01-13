import 'package:flutter/material.dart';
import 'pages/data_barang.dart';

void main() {
  runApp(
    MyApp()
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinjam Barang Perpustakaan',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: DataBarang(),
    );
  }
}
