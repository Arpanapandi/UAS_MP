<?php

namespace Database\Seeders;

use App\Models\Barang;
use Illuminate\Database\Seeder;

class BarangSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $barangs = [
            [
                'nama_barang' => 'Terminal',
                'stok' => 50,
                'keterangan' => 'Terminal kabel roll berkualitas',
                'gambar' => 'terminal.jpg',
            ],
            [
                'nama_barang' => 'Kursi meja',
                'stok' => 30,
                'keterangan' => 'Kursi lipat dengan meja senderan',
                'gambar' => 'kursi_meja.jpg',
            ],
            [
                'nama_barang' => 'Kursi',
                'stok' => 100,
                'keterangan' => 'Kursi standar untuk pertemuan',
                'gambar' => 'kursi.png',
            ],
            [
                'nama_barang' => 'Spidol',
                'stok' => 200,
                'keterangan' => 'Spidol Snowman whiteboard marker',
                'gambar' => 'spidol.jpg',
            ],
            [
                'nama_barang' => 'Meja',
                'stok' => 25,
                'keterangan' => 'Meja belajar/kerja kayu minimalis',
                'gambar' => 'meja.jpg',
            ],
        ];

        foreach ($barangs as $item) {
            Barang::create($item);
        }

        $this->command->info('Data barang berhasil ditambahkan!');
    }
}
