<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PeminjamanResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'barang_id' => $this->barang_id,
            'jml_peminjaman' => (int) $this->jml_peminjaman,
            'tanggal_pinjam' => $this->tanggal_pinjam,
            'status' => strtolower($this->status), // Pastikan lowercase
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'user' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'email' => $this->user->email,
            ],
            'barang' => new BarangResource($this->barang),
        ];
    }
}
