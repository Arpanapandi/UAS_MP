import 'dart:ui';
import 'package:aplikasi_project_uas/provider/peminjaman_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aplikasi_project_uas/provider/item_provider.dart';
import 'package:aplikasi_project_uas/model/Model_data-barang.dart';

class DataBarang extends StatefulWidget {
  DataBarang({super.key});

  @override
  State<DataBarang> createState() => _DataBarangState();
}

class _DataBarangState extends State<DataBarang> { // pakai ini "_" karena _DataBarangState itu private (hanya dipakai di file ini).
  List<int> jumlahPinjam = []; // variabel list kosong ini nanti di isi lewat _syncJumlahPinjam

  void _syncJumlahPinjam(int length) {
    /* 
    kita buat logika:
    jika panjang jumlahPinjam SAMA, kode di dalam {} dilewati dan fungsi langsung selesai. 
    jika TIDAK sama dengan length, maka kode di dalam {} dijalankan.
    */
    if (jumlahPinjam.length != length) {

      /* 
      selanjutnya, kita ingin agar setiap barang selalu punya “slot” jumlah pinjam sendiri, mulai dari nol.
      - dengan List.generate kita bisa bikin list baru dengan panjang length, dan isi awal semua elemen = 0, 
        yang kita simpan di varibel "_". sebenarnya variable nya ga penting, yg penting cuma 0 nya aja
      */
      // jumlahPinjam = List.generate(length, (_) => 0);
      jumlahPinjam = List.generate(length, (_) => 0);
    }
  }

  /* 
  selanjutnya kita buat logika untuk tambah jumlah barang
  - kita buat parameter stok untuk menentukan batas maksimal yang boleh di pinjam untuk barang itu 
  - jika jumlahPinjam masih lebih kecil dari stok, ya berarti masih bisa nambah
  - selanjutnya kan di bawah kita buat tombol untuk tambah jumlah barang, agar ui otomatis update ya kita harus pake setState
    Kalau ga pakai setState, jumlah pinjam tetap bertambah di memori, tapi UI ga update.
  */
  void tambah(int i, int stok) {
    if (jumlahPinjam[i] < stok) {
      setState(() => jumlahPinjam[i]++);
    }
  }

  /*
  ini untuk bagian kurangi jumlaj barangnya
  */
  void kurang(int i) {
    if (jumlahPinjam[i] > 0) {
      setState(() => jumlahPinjam[i]--);
    }
  }


  /// ================= GLASS CARD =================
  /* 
  Agar efek kaca (glassCard) ditulis sekali dan bisa dipakai di mana saja. Isi/konten kartu ditulis terpisah.
  nanti di bawah tinggal di return, dan ini harus di return. karena bagian ini itu "required widget child" atau koran tanpa isi
  */
  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // ini yang buat motong widget, semuanya sama isinya ikut kepotong
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // BackdropFilter nge-blur apa pun yang ada di belakang kartu. Kalau belakangnya polos/gelap, blur nggak keliatan. ubah ke 100 biar keliatan
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03), // bg card nya
            borderRadius: BorderRadius.circular(16), // kalo ini punya container, ga akan ngaruh ke isi (img sm tombol)
            border: Border.all(color: Colors.white.withOpacity(0.05)), // ini border atau sisi nya  
          ),
          child: child, // di bawah, ini di isi oleh child column sehingga memiliki banyak widget atau turunan 
        ),
      ),
    );
  }

  /// ================= GLOW SPOT (BACKGROUND) =================
  /* 
  sama kaya glass card, agar bg reusable dan bisa ubah isi (ukuran & warna) tanpa bikin kode baru.. dengan menyediakan parameter size dan color
  - disana width: size, color: color, dll. di isi oleh parameter "double size" dan "Color color. 
  */
  Widget _buildGlowSpot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final items = provider.items;

    _syncJumlahPinjam(items.length);

    return Scaffold(
      backgroundColor: Color(0xFF030712),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlowSpot(250, Color.fromARGB(255, 36, 52, 77).withOpacity(0.15)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlowSpot(300, Color(0xFF8B5CF6).withOpacity(0.15)),
          ),

          /// ================= CONTENT =================
          Column(
            children: [
              /// APPBAR
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  // gradient: LinearGradient(colors: [ Color(0xFF1E3A8A), Color(0xFF312E81)]),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.white),
                    SizedBox(width: 10),
                    Text('PINJAM BARANG KAMPUS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: _showKeranjang,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              Text('Daftar Barang', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),

              SizedBox(height: 16),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        
                        return glassCard(
                          child: Column(
                            children: [
                              Expanded(
                                child: 
                                  Image.asset('image/laptop.jpg', fit: BoxFit.cover)),
                              SizedBox(height: 8),
                              Text(item.nama,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('Stok: ${item.stok}', style: TextStyle(color: Color(0xFF34D399))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Colors.white),
                                    onPressed: () => kurang(i),
                                  ),
                                  Text(
                                    jumlahPinjam[i].toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.white),
                                    onPressed: () => tambah(i, item.stok),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: jumlahPinjam[i] > 0
                                  ? () {_konfirmasiPinjam(
                                          provider,
                                          items[i],
                                          jumlahPinjam[i],
                                          i,
                                        );
                                       }
                                  : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: jumlahPinjam[i] > 0
                                      ? Colors.blueAccent
                                      : Colors.grey,
                                  minimumSize: Size(double.infinity, 36),
                                ),
                                child: Text('Pinjam', style:TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= KERANJANG =================
  void _showKeranjang() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Color.fromARGB(255, 66, 77, 108),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420), // ini untuk batas maksimal desktop

          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Keranjang Pinjaman', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),

                Consumer<PeminjamanProvider>(
                  builder: (context, peminjamanProvider, _) {
                    final peminjaman = peminjamanProvider.listBelumDikembalikan;
                    if (peminjaman.isEmpty) {
                      return Text('Belum ada pinjaman', style: TextStyle(color: Colors.white54));
                    }
                    return Column(
                      children: peminjaman.map((p) {
                        return ListTile(
                          title: Text(p.namaBarang, style: TextStyle(color: Colors.white)),
                          trailing: Text('x${p.jumlah}', style: TextStyle(color: Colors.white70)),
                        );
                      }).toList(),
                    );
                  },
                ),

                SizedBox(height: 12),

                ElevatedButton(onPressed: () => Navigator.pop(context),
                  child: Text('Tutup'),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  /// ================= KONFIRMASI =================
  Future<void> _konfirmasiPinjam(
    ItemProvider provider,
    Item item,
    int jumlah,
    int index,

  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Konfirmasi Pinjam', style: TextStyle(fontWeight: FontWeight.bold),),
        content: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Apakah anda yakin akan meminjam barang ini?\n', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'Pengembalian atau pembatalan harus dikonfirmasi ke petugas perpustakaan.', style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(onPressed: () => Navigator.pop(context, true),
            child: Text('Ya'),
          ),
        ],
      ),
    );

    if (ok == true) {
      for (int i = 0; i < jumlah; i++) {
        provider.kurangiStok(item.id);
      }

      Provider.of<PeminjamanProvider>(context, listen: false)
          .tambahPeminjaman(item, jumlah);

      setState(() {
        jumlahPinjam[index] = 0;
      });
    }
  }
}
