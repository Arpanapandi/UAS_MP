<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Barang extends Model
{
    use HasFactory;

    protected $fillable = [
        'nama_barang',
        'stok',
        'keterangan',
    ];

    /**
     * Get the peminjaman for the barang.
     */
    public function peminjaman()
    {
        return $this->hasMany(Peminjaman::class);
    }
}

