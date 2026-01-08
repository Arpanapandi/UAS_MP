<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Peminjaman extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'barang_id',
        'tanggal_pinjam',
        'status',
    ];

    protected $casts = [
        'tanggal_pinjam' => 'date',
    ];

    /**
     * Get the user that owns the peminjaman.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the barang that owns the peminjaman.
     */
    public function barang()
    {
        return $this->belongsTo(Barang::class);
    }
}

