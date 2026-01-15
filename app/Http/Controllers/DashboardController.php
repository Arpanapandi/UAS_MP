<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use App\Models\Peminjaman;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    /**
     * Display the dashboard.
     */
    public function index()
    {
        $user = auth()->user();

        if ($user->role === 'admin') {
            $totalBarang = Barang::count();
            $totalPeminjaman = Peminjaman::count();
            $peminjamanAktif = Peminjaman::where('status', 'dipinjam')->count();
            $peminjamanTerbaru = Peminjaman::with(['user', 'barang'])->latest()->take(5)->get();
        } else {
            $totalBarang = Barang::count();
            $totalPeminjaman = Peminjaman::where('user_id', $user->id)->count();
            $peminjamanAktif = Peminjaman::where('user_id', $user->id)
                ->where('status', 'dipinjam')->count();
            $peminjamanTerbaru = Peminjaman::with(['user', 'barang'])
                ->where('user_id', $user->id)
                ->latest()
                ->take(5)
                ->get();
        }

        return view('dashboard', compact(
            'totalBarang',
            'totalPeminjaman',
            'peminjamanAktif',
            'peminjamanTerbaru'
        ));
    }
}

