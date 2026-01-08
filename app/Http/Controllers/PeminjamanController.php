<?php

namespace App\Http\Controllers;

use App\Models\Peminjaman;
use App\Models\Barang;
use Illuminate\Http\Request;

class PeminjamanController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $user = $request->user();

        // Admin bisa melihat semua, peminjam hanya miliknya
        if ($user->role === 'admin') {
            $peminjaman = Peminjaman::with(['user', 'barang'])->get();
        } else {
            $peminjaman = Peminjaman::with(['user', 'barang'])
                ->where('user_id', $user->id)
                ->get();
        }

        return response()->json([
            'status' => true,
            'message' => 'Data peminjaman berhasil diambil.',
            'data' => $peminjaman,
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'barang_id' => 'required|exists:barang,id',
            'tanggal_pinjam' => 'required|date',
            'status' => 'required|in:dipinjam,dikembalikan',
        ]);

        // Cek stok barang jika status dipinjam
        if ($request->status === 'dipinjam') {
            $barang = Barang::find($request->barang_id);
            if (!$barang) {
                return response()->json([
                    'status' => false,
                    'message' => 'Barang tidak ditemukan.',
                ], 404);
            }

            if ($barang->stok <= 0) {
                return response()->json([
                    'status' => false,
                    'message' => 'Stok barang tidak tersedia.',
                ], 400);
            }

            // Kurangi stok
            $barang->decrement('stok');
        }

        $peminjaman = Peminjaman::create([
            'user_id' => $request->user()->id,
            'barang_id' => $request->barang_id,
            'tanggal_pinjam' => $request->tanggal_pinjam,
            'status' => $request->status,
        ]);

        $peminjaman->load(['user', 'barang']);

        return response()->json([
            'status' => true,
            'message' => 'Peminjaman berhasil ditambahkan.',
            'data' => $peminjaman,
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        $peminjaman = Peminjaman::with(['user', 'barang'])->find($id);

        if (!$peminjaman) {
            return response()->json([
                'status' => false,
                'message' => 'Peminjaman tidak ditemukan.',
            ], 404);
        }

        // Peminjam hanya bisa melihat peminjaman miliknya
        if ($user->role !== 'admin' && $peminjaman->user_id !== $user->id) {
            return response()->json([
                'status' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        return response()->json([
            'status' => true,
            'message' => 'Data peminjaman berhasil diambil.',
            'data' => $peminjaman,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();
        $peminjaman = Peminjaman::find($id);

        if (!$peminjaman) {
            return response()->json([
                'status' => false,
                'message' => 'Peminjaman tidak ditemukan.',
            ], 404);
        }

        // Peminjam hanya bisa update peminjaman miliknya
        if ($user->role !== 'admin' && $peminjaman->user_id !== $user->id) {
            return response()->json([
                'status' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        $request->validate([
            'barang_id' => 'sometimes|exists:barang,id',
            'tanggal_pinjam' => 'sometimes|date',
            'status' => 'sometimes|in:dipinjam,dikembalikan',
        ]);

        // Handle perubahan status
        if ($request->has('status')) {
            $oldStatus = $peminjaman->status;
            $newStatus = $request->status;

            if ($oldStatus === 'dipinjam' && $newStatus === 'dikembalikan') {
                // Kembalikan stok
                $barang = Barang::find($peminjaman->barang_id);
                if ($barang) {
                    $barang->increment('stok');
                }
            } elseif ($oldStatus === 'dikembalikan' && $newStatus === 'dipinjam') {
                // Kurangi stok
                $barangId = $request->barang_id ?? $peminjaman->barang_id;
                $barang = Barang::find($barangId);
                if ($barang && $barang->stok <= 0) {
                    return response()->json([
                        'status' => false,
                        'message' => 'Stok barang tidak tersedia.',
                    ], 400);
                }
                if ($barang) {
                    $barang->decrement('stok');
                }
            }
        }

        $peminjaman->update($request->all());
        $peminjaman->load(['user', 'barang']);

        return response()->json([
            'status' => true,
            'message' => 'Peminjaman berhasil diupdate.',
            'data' => $peminjaman,
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $peminjaman = Peminjaman::find($id);

        if (!$peminjaman) {
            return response()->json([
                'status' => false,
                'message' => 'Peminjaman tidak ditemukan.',
            ], 404);
        }

        // Peminjam hanya bisa hapus peminjaman miliknya
        if ($user->role !== 'admin' && $peminjaman->user_id !== $user->id) {
            return response()->json([
                'status' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        // Jika status dipinjam, kembalikan stok
        if ($peminjaman->status === 'dipinjam') {
            $barang = Barang::find($peminjaman->barang_id);
            if ($barang) {
                $barang->increment('stok');
            }
        }

        $peminjaman->delete();

        return response()->json([
            'status' => true,
            'message' => 'Peminjaman berhasil dihapus.',
        ]);
    }
}

