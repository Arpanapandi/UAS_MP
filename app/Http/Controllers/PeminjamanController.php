<?php

namespace App\Http\Controllers;

use App\Models\Peminjaman;
use App\Models\Barang;
use Illuminate\Http\Request;
use App\Http\Resources\PeminjamanResource;

/**
 * @OA\Tag(
 *     name="Peminjaman",
 *     description="API untuk mengelola data peminjaman. Admin bisa melihat semua peminjaman, peminjam hanya bisa melihat peminjaman miliknya sendiri."
 * )
 */
class PeminjamanController extends Controller
{
    /**
     * @OA\Get(
     *     path="/peminjaman",
     *     tags={"Peminjaman"},
     *     summary="Get all peminjaman",
     *     description="Mendapatkan semua data peminjaman. Admin bisa melihat semua peminjaman, peminjam hanya bisa melihat peminjaman miliknya sendiri. user_id otomatis diambil dari token login.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Data peminjaman berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Data peminjaman berhasil diambil."),
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(
     *                     type="object",
     *                     @OA\Property(property="id", type="integer", example=1),
     *                     @OA\Property(property="user_id", type="integer", example=2),
     *                     @OA\Property(property="barang_id", type="integer", example=1),
     *                     @OA\Property(property="jml_peminjaman", type="integer", example=2),
     *                     @OA\Property(property="tanggal_pinjam", type="string", format="date", example="2024-01-15"),
     *                     @OA\Property(property="status", type="string", example="dipinjam", enum={"dipinjam", "dikembalikan"}),
     *                     @OA\Property(property="user", type="object", description="Data user peminjam"),
     *                     @OA\Property(property="barang", type="object", description="Data barang yang dipinjam")
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(response=401, description="Unauthorized - Token tidak valid")
     * )
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
            'data' => PeminjamanResource::collection($peminjaman),
        ]);
    }

    /**
     * @OA\Post(
     *     path="/peminjaman",
     *     tags={"Peminjaman"},
     *     summary="Create peminjaman baru",
     *     description="Menambahkan peminjaman baru. user_id otomatis diambil dari token login. Stok barang otomatis berkurang jika status = 'dipinjam'.",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"barang_id","jml_peminjaman","tanggal_pinjam","status"},
     *             @OA\Property(property="barang_id", type="integer", example=1, description="ID barang yang dipinjam"),
     *             @OA\Property(property="jml_peminjaman", type="integer", example=2, description="Jumlah barang yang dipinjam"),
     *             @OA\Property(property="tanggal_pinjam", type="string", format="date", example="2024-01-15", description="Tanggal pinjam (format: YYYY-MM-DD)"),
     *             @OA\Property(property="status", type="string", example="dipinjam", enum={"dipinjam", "dikembalikan"}, description="Status peminjaman")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Peminjaman berhasil ditambahkan",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Peminjaman berhasil ditambahkan."),
     *             @OA\Property(property="data", type="object", description="Data peminjaman yang baru dibuat")
     *         )
     *     ),
     *     @OA\Response(response=400, description="Stok barang tidak tersedia"),
     *     @OA\Response(response=404, description="Barang tidak ditemukan"),
     *     @OA\Response(response=422, description="Validation error")
     * )
     */
    public function store(Request $request)
    {
        $request->validate([
            'barang_id' => 'required|exists:barang,id',
            'jml_peminjaman' => 'required|integer|min:1',
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

            if ($barang->stok < $request->jml_peminjaman) {
                return response()->json([
                    'status' => false,
                    'message' => 'Stok barang tidak mencukupi. Stok tersedia: ' . $barang->stok,
                ], 400);
            }

            // Kurangi stok
            $barang->decrement('stok', $request->jml_peminjaman);
        }

        $peminjaman = Peminjaman::create([
            'user_id' => $request->user()->id,
            'barang_id' => $request->barang_id,
            'jml_peminjaman' => $request->jml_peminjaman,
            'tanggal_pinjam' => $request->tanggal_pinjam,
            'status' => $request->status,
        ]);

        $peminjaman->load(['user', 'barang']);

        return response()->json([
            'status' => true,
            'message' => 'Peminjaman berhasil ditambahkan.',
            'data' => new PeminjamanResource($peminjaman),
        ], 201);
    }

    /**
     * @OA\Get(
     *     path="/peminjaman/{id}",
     *     tags={"Peminjaman"},
     *     summary="Get peminjaman by ID",
     *     description="Mendapatkan data peminjaman berdasarkan ID. Admin bisa melihat semua, peminjam hanya bisa melihat peminjaman miliknya sendiri.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID peminjaman",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Data peminjaman berhasil diambil",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Data peminjaman berhasil diambil."),
     *             @OA\Property(property="data", type="object")
     *         )
     *     ),
     *     @OA\Response(response=403, description="Akses ditolak - Peminjam hanya bisa melihat peminjaman miliknya"),
     *     @OA\Response(response=404, description="Peminjaman tidak ditemukan")
     * )
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
            'data' => new PeminjamanResource($peminjaman),
        ]);
    }

    /**
     * @OA\Put(
     *     path="/peminjaman/{id}",
     *     tags={"Peminjaman"},
     *     summary="Update peminjaman",
     *     description="Update data peminjaman. Admin bisa update semua, peminjam hanya bisa update peminjaman miliknya. Jika status berubah dari 'dipinjam' ke 'dikembalikan', stok barang otomatis kembali.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID peminjaman",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=false,
     *         @OA\JsonContent(
     *             @OA\Property(property="barang_id", type="integer", example=1, description="ID barang (opsional)"),
     *             @OA\Property(property="jml_peminjaman", type="integer", example=2, description="Jumlah barang (opsional)"),
     *             @OA\Property(property="tanggal_pinjam", type="string", format="date", example="2024-01-15", description="Tanggal pinjam (opsional)"),
     *             @OA\Property(property="status", type="string", example="dikembalikan", enum={"dipinjam", "dikembalikan"}, description="Status peminjaman (opsional)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Peminjaman berhasil diupdate",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Peminjaman berhasil diupdate."),
     *             @OA\Property(property="data", type="object")
     *         )
     *     ),
     *     @OA\Response(response=400, description="Stok barang tidak tersedia"),
     *     @OA\Response(response=403, description="Akses ditolak"),
     *     @OA\Response(response=404, description="Peminjaman tidak ditemukan")
     * )
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
            'jml_peminjaman' => 'sometimes|integer|min:1',
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
                    $barang->increment('stok', $peminjaman->jml_peminjaman);
                }
            } elseif ($oldStatus === 'dikembalikan' && $newStatus === 'dipinjam') {
                // Kurangi stok
                $barangId = $request->barang_id ?? $peminjaman->barang_id;
                $jmlPeminjaman = $request->jml_peminjaman ?? $peminjaman->jml_peminjaman;
                $barang = Barang::find($barangId);
                
                if ($barang && $barang->stok < $jmlPeminjaman) {
                    return response()->json([
                        'status' => false,
                        'message' => 'Stok barang tidak mencukupi.',
                    ], 400);
                }
                
                if ($barang) {
                    $barang->decrement('stok', $jmlPeminjaman);
                }
            } elseif ($oldStatus === 'dipinjam' && $newStatus === 'dipinjam' && $request->has('jml_peminjaman')) {
                // Jika masih dalam status dipinjam tapi jumlahnya diubah
                $newJml = $request->jml_peminjaman;
                $oldJml = $peminjaman->jml_peminjaman;
                $selisih = $newJml - $oldJml;

                $barang = Barang::find($peminjaman->barang_id);
                if ($barang) {
                    if ($selisih > 0) {
                        // Jumlah pinjam bertambah, kurangi stok
                        if ($barang->stok < $selisih) {
                            return response()->json([
                                'status' => false,
                                'message' => 'Stok barang tidak mencukupi untuk penambahan jumlah.',
                            ], 400);
                        }
                        $barang->decrement('stok', $selisih);
                    } elseif ($selisih < 0) {
                        // Jumlah pinjam berkurang, kembalikan stok
                        $barang->increment('stok', abs($selisih));
                    }
                }
            }
        }

        $peminjaman->update($request->all());
        $peminjaman->load(['user', 'barang']);

        return response()->json([
            'status' => true,
            'message' => 'Peminjaman berhasil diupdate.',
            'data' => new PeminjamanResource($peminjaman),
        ]);
    }

    /**
     * @OA\Delete(
     *     path="/peminjaman/{id}",
     *     tags={"Peminjaman"},
     *     summary="Delete peminjaman",
     *     description="Hapus data peminjaman. Admin bisa hapus semua, peminjam hanya bisa hapus peminjaman miliknya. Jika status = 'dipinjam', stok barang otomatis dikembalikan.",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID peminjaman",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Peminjaman berhasil dihapus",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Peminjaman berhasil dihapus.")
     *         )
     *     ),
     *     @OA\Response(response=403, description="Akses ditolak"),
     *     @OA\Response(response=404, description="Peminjaman tidak ditemukan")
     * )
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
                $barang->increment('stok', $peminjaman->jml_peminjaman);
            }
        }

        $peminjaman->delete();

        return response()->json([
            'status' => true,
            'message' => 'Peminjaman berhasil dihapus.',
        ]);
    }
}

