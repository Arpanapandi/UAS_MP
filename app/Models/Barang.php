<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Barang extends Model
{
    use HasFactory;

    protected $table = 'barang';

    protected $fillable = [
        'nama_barang',
        'stok',
        'keterangan',
        'gambar',
    ];

    protected $appends = ['gambar_url'];

    public function getGambarUrlAttribute()
    {
        if ($this->gambar) {
            return url('images/barang/' . $this->gambar);
        }
        return null;
    }

    /**
     * Get the peminjaman for the barang.
     */
    public function peminjaman()
    {
        return $this->hasMany(Peminjaman::class);
    }
}

