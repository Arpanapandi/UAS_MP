<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use Illuminate\Http\Request;

class BarangController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $barang = Barang::all();

        return response()->json([
            'status' => true,
            'message' => 'Data barang berhasil diambil.',
            'data' => $barang,
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'nama_barang' => 'required|string|max:255',
            'stok' => 'required|integer|min:0',
            'keterangan' => 'nullable|string',
        ]);

        $barang = Barang::create($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Barang berhasil ditambahkan.',
            'data' => $barang,
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $barang = Barang::find($id);

        if (!$barang) {
            return response()->json([
                'status' => false,
                'message' => 'Barang tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Data barang berhasil diambil.',
            'data' => $barang,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $barang = Barang::find($id);

        if (!$barang) {
            return response()->json([
                'status' => false,
                'message' => 'Barang tidak ditemukan.',
            ], 404);
        }

        $request->validate([
            'nama_barang' => 'required|string|max:255',
            'stok' => 'required|integer|min:0',
            'keterangan' => 'nullable|string',
        ]);

        $barang->update($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Barang berhasil diupdate.',
            'data' => $barang,
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $barang = Barang::find($id);

        if (!$barang) {
            return response()->json([
                'status' => false,
                'message' => 'Barang tidak ditemukan.',
            ], 404);
        }

        $barang->delete();

        return response()->json([
            'status' => true,
            'message' => 'Barang berhasil dihapus.',
        ]);
    }
}

