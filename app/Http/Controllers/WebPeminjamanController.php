<?php

namespace App\Http\Controllers;

use App\Models\Peminjaman;
use App\Models\Barang;
use Illuminate\Http\Request;

class WebPeminjamanController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = auth()->user();

        if ($user->role === 'admin') {
            $peminjaman = Peminjaman::with(['user', 'barang'])->latest()->paginate(10);
        } else {
            $peminjaman = Peminjaman::with(['user', 'barang'])
                ->where('user_id', $user->id)
                ->latest()
                ->paginate(10);
        }

        return view('peminjaman.index', compact('peminjaman'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $barang = Barang::where('stok', '>', 0)->get();
        return view('peminjaman.create', compact('barang'));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'barang_id' => 'required|exists:barang,id',
            'jml_peminjaman' => 'required|integer|min:1',
            'tanggal_pinjam' => 'required|date',
            'status' => 'required|in:dipinjam,dikembalikan',
        ]);

        if ($request->status === 'dipinjam') {
            $barang = Barang::findOrFail($request->barang_id);
            if ($barang->stok < $request->jml_peminjaman) {
                return back()->withErrors(['barang_id' => 'Stok barang tidak cukup. Tersedia: ' . $barang->stok])->withInput();
            }
            $barang->decrement('stok', $request->jml_peminjaman);
        }

        Peminjaman::create([
            'user_id' => auth()->id(),
            'barang_id' => $request->barang_id,
            'jml_peminjaman' => $request->jml_peminjaman,
            'tanggal_pinjam' => $request->tanggal_pinjam,
            'status' => $request->status,
        ]);

        return redirect()->route('peminjaman.index')
            ->with('success', 'Peminjaman berhasil ditambahkan.');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit($id)
    {
        $peminjaman = Peminjaman::findOrFail($id);
        $user = auth()->user();

        if ($user->role !== 'admin' && $peminjaman->user_id !== $user->id) {
            abort(403);
        }

        $barang = Barang::all();
        return view('peminjaman.edit', compact('peminjaman', 'barang'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $peminjaman = Peminjaman::findOrFail($id);
        $user = auth()->user();

        if ($user->role !== 'admin' && $peminjaman->user_id !== $user->id) {
            abort(403);
        }

        $request->validate([
            'barang_id' => 'sometimes|exists:barang,id',
            'jml_peminjaman' => 'sometimes|integer|min:1',
            'tanggal_pinjam' => 'sometimes|date',
            'status' => 'sometimes|in:dipinjam,dikembalikan',
        ]);

        // Handle perubahan status
        if ($request->has('status')) {
            $oldStatus = $peminjaman->status;
            $newStatus = $request->status;

            if ($oldStatus === 'dipinjam' && $newStatus === 'dikembalikan') {
                $barang = Barang::find($peminjaman->barang_id);
                if ($barang) {
                    $barang->increment('stok', $peminjaman->jml_peminjaman);
                }
            } elseif ($oldStatus === 'dikembalikan' && $newStatus === 'dipinjam') {
                $barangId = $request->barang_id ?? $peminjaman->barang_id;
                $jmlPeminjaman = $request->jml_peminjaman ?? $peminjaman->jml_peminjaman;
                $barang = Barang::find($barangId);
                if ($barang && $barang->stok < $jmlPeminjaman) {
                    return back()->withErrors(['barang_id' => 'Stok barang tidak cukup.'])->withInput();
                }
                if ($barang) {
                    $barang->decrement('stok', $jmlPeminjaman);
                }
            } elseif ($oldStatus === 'dipinjam' && $newStatus === 'dipinjam' && $request->has('jml_peminjaman')) {
                $newJml = $request->jml_peminjaman;
                $oldJml = $peminjaman->jml_peminjaman;
                $selisih = $newJml - $oldJml;

                $barang = Barang::find($peminjaman->barang_id);
                if ($barang) {
                    if ($selisih > 0) {
                        if ($barang->stok < $selisih) {
                            return back()->withErrors(['jml_peminjaman' => 'Stok tidak cukup untuk penambahan jumlah.'])->withInput();
                        }
                        $barang->decrement('stok', $selisih);
                    } elseif ($selisih < 0) {
                        $barang->increment('stok', abs($selisih));
                    }
                }
            }
        }

        $peminjaman->update($request->all());

        return redirect()->route('peminjaman.index')
            ->with('success', 'Peminjaman berhasil diupdate.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $peminjaman = Peminjaman::findOrFail($id);
        $user = auth()->user();

        if ($user->role !== 'admin' && $peminjaman->user_id !== $user->id) {
            abort(403);
        }

        if ($peminjaman->status === 'dipinjam') {
            $barang = Barang::find($peminjaman->barang_id);
            if ($barang) {
                $barang->increment('stok', $peminjaman->jml_peminjaman);
            }
        }

        $peminjaman->delete();

        return redirect()->route('peminjaman.index')
            ->with('success', 'Peminjaman berhasil dihapus.');
    }
}

