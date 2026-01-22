<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use Illuminate\Http\Request;
use App\Http\Resources\BarangResource;

/**
 * @OA\Tag(
 *     name="Barang",
 *     description="API untuk mengelola data barang. Hanya bisa diakses oleh admin."
 * )
 */
class BarangController extends Controller
{
    /**
     * @OA\Get(
     *     path="/barang",
     *     tags={"Barang"},
     *     summary="Get all barang",
     *     description="Mendapatkan semua data barang. Hanya admin yang bisa mengakses endpoint ini.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Data barang berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Data barang berhasil diambil."),
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="nama_barang", type="string", example="Laptop"),
     *                     @OA\Property(property="stok", type="integer", example=10),
     *                     @OA\Property(property="keterangan", type="string", nullable=true, example="Laptop untuk keperluan kerja"),
     *                     @OA\Property(property="created_at", type="string", format="date-time"),
     *                     @OA\Property(property="updated_at", type="string", format="date-time")
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(response=401, description="Unauthorized - Token tidak valid"),
     *     @OA\Response(response=403, description="Forbidden - Hanya admin yang bisa mengakses")
     * )
     */
    public function index()
    {
        $barang = Barang::all();

        return response()->json([
            'status' => true,
            'message' => 'Data barang berhasil diambil.',
            'data' => BarangResource::collection($barang),
        ]);
    }

    /**
     * @OA\Post(
     *     path="/barang",
     *     tags={"Barang"},
     *     summary="Create barang baru",
     *     description="Menambahkan barang baru ke database. Hanya admin yang bisa mengakses endpoint ini.",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"nama_barang","stok"},
     *             @OA\Property(property="nama_barang", type="string", example="Laptop", description="Nama barang"),
     *             @OA\Property(property="stok", type="integer", example=10, minimum=0, description="Jumlah stok barang"),
     *             @OA\Property(property="keterangan", type="string", nullable=true, example="Laptop untuk keperluan kerja", description="Keterangan barang (opsional)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Barang berhasil ditambahkan",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Barang berhasil ditambahkan."),
     *             @OA\Property(property="data", type="object", description="Data barang yang baru dibuat")
     *         )
     *     ),
     *     @OA\Response(response=403, description="Forbidden - Hanya admin yang bisa mengakses"),
     *     @OA\Response(response=422, description="Validation error")
     * )
     */
    public function store(Request $request)
    {
        $request->validate([
            'nama_barang' => 'required|string|max:255',
            'stok' => 'required|integer|min:0',
            'keterangan' => 'nullable|string',
            'gambar' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $data = $request->all();

        if ($request->hasFile('gambar')) {
            $imageName = time() . '.' . $request->gambar->extension();
            $request->gambar->move(public_path('images/barang'), $imageName);
            $data['gambar'] = $imageName;
        }

        $barang = Barang::create($data);

        return response()->json([
            'status' => true,
            'message' => 'Barang berhasil ditambahkan.',
            'data' => new BarangResource($barang),
        ], 201);
    }

    /**
     * @OA\Get(
     *     path="/barang/{id}",
     *     tags={"Barang"},
     *     summary="Get barang by ID",
     *     description="Mendapatkan data barang berdasarkan ID. Hanya admin yang bisa mengakses endpoint ini.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID barang",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Data barang berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Data barang berhasil diambil."),
     *             @OA\Property(property="data", type="object")
     *         )
     *     ),
     *     @OA\Response(response=404, description="Barang tidak ditemukan"),
     *     @OA\Response(response=403, description="Forbidden - Hanya admin yang bisa mengakses")
     * )
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
            'data' => new BarangResource($barang),
        ]);
    }

    /**
     * @OA\Put(
     *     path="/barang/{id}",
     *     tags={"Barang"},
     *     summary="Update barang",
     *     description="Update data barang berdasarkan ID. Hanya admin yang bisa mengakses endpoint ini.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID barang",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"nama_barang","stok"},
     *             @OA\Property(property="nama_barang", type="string", example="Laptop Updated"),
     *             @OA\Property(property="stok", type="integer", example=15, minimum=0),
     *             @OA\Property(property="keterangan", type="string", nullable=true, example="Updated keterangan")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Barang berhasil diupdate",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Barang berhasil diupdate."),
     *             @OA\Property(property="data", type="object")
     *         )
     *     ),
     *     @OA\Response(response=404, description="Barang tidak ditemukan"),
     *     @OA\Response(response=403, description="Forbidden - Hanya admin yang bisa mengakses")
     * )
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
            'gambar' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $data = $request->all();

        if ($request->hasFile('gambar')) {
            // Hapus gambar lama jika ada
            if ($barang->gambar) {
                $oldImagePath = public_path('images/barang/' . $barang->gambar);
                if (file_exists($oldImagePath)) {
                    unlink($oldImagePath);
                }
            }

            $imageName = time() . '.' . $request->gambar->extension();
            $request->gambar->move(public_path('images/barang'), $imageName);
            $data['gambar'] = $imageName;
        }

        $barang->update($data);

        return response()->json([
            'status' => true,
            'message' => 'Barang berhasil diupdate.',
            'data' => new BarangResource($barang),
        ]);
    }

    /**
     * @OA\Delete(
     *     path="/barang/{id}",
     *     tags={"Barang"},
     *     summary="Delete barang",
     *     description="Hapus data barang berdasarkan ID. Hanya admin yang bisa mengakses endpoint ini.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID barang",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Barang berhasil dihapus",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Barang berhasil dihapus.")
     *         )
     *     ),
     *     @OA\Response(response=404, description="Barang tidak ditemukan"),
     *     @OA\Response(response=403, description="Forbidden - Hanya admin yang bisa mengakses")
     * )
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

        // Hapus gambar jika ada
        if ($barang->gambar) {
            $imagePath = public_path('images/barang/' . $barang->gambar);
            if (file_exists($imagePath)) {
                unlink($imagePath);
            }
        }

        $barang->delete();

        return response()->json([
            'status' => true,
            'message' => 'Barang berhasil dihapus.',
        ]);
    }
}

