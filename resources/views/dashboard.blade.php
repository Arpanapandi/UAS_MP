@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')
<div class="mb-6">
    <h1 class="text-3xl font-bold">Dashboard</h1>
</div>

<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
    <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-600 text-sm font-medium mb-2">Total Barang</h3>
        <p class="text-3xl font-bold text-blue-600">{{ $totalBarang }}</p>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-600 text-sm font-medium mb-2">Total Peminjaman</h3>
        <p class="text-3xl font-bold text-green-600">{{ $totalPeminjaman }}</p>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-gray-600 text-sm font-medium mb-2">Peminjaman Aktif</h3>
        <p class="text-3xl font-bold text-orange-600">{{ $peminjamanAktif }}</p>
    </div>
</div>

<div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-xl font-bold mb-4">Peminjaman Terbaru</h2>
    
    @if($peminjamanTerbaru->count() > 0)
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Barang</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Peminjam</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal Pinjam</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    @foreach($peminjamanTerbaru as $p)
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">{{ $p->barang->nama_barang }}</td>
                            <td class="px-6 py-4 whitespace-nowrap">{{ $p->user->name }}</td>
                            <td class="px-6 py-4 whitespace-nowrap">{{ $p->tanggal_pinjam }}</td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-2 py-1 text-xs rounded-full {{ $p->status === 'dipinjam' ? 'bg-orange-100 text-orange-800' : 'bg-green-100 text-green-800' }}">
                                    {{ $p->status }}
                                </span>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    @else
        <p class="text-gray-500">Belum ada data peminjaman.</p>
    @endif
</div>
@endsection

