@extends('layouts.app')

@section('title', 'Tambah Peminjaman')

@section('content')
<div class="max-w-2xl mx-auto bg-white rounded-lg shadow-md p-6">
    <h2 class="text-2xl font-bold mb-6">Tambah Peminjaman</h2>
    
    <form method="POST" action="{{ route('peminjaman.store') }}">
        @csrf
        
        <div class="mb-4">
            <label for="barang_id" class="block text-gray-700 font-medium mb-2">Barang *</label>
            <select id="barang_id" 
                    name="barang_id" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required>
                <option value="">Pilih Barang</option>
                @foreach($barang as $b)
                    <option value="{{ $b->id }}" {{ old('barang_id') == $b->id ? 'selected' : '' }}>
                        {{ $b->nama_barang }} (Stok: {{ $b->stok }})
                    </option>
                @endforeach
            </select>
        </div>

        <div class="mb-4">
            <label for="tanggal_pinjam" class="block text-gray-700 font-medium mb-2">Tanggal Pinjam *</label>
            <input type="date" 
                   id="tanggal_pinjam" 
                   name="tanggal_pinjam" 
                   value="{{ old('tanggal_pinjam', date('Y-m-d')) }}"
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                   required>
        </div>

        <div class="mb-4">
            <label for="status" class="block text-gray-700 font-medium mb-2">Status *</label>
            <select id="status" 
                    name="status" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required>
                <option value="dipinjam" {{ old('status') == 'dipinjam' ? 'selected' : '' }}>Dipinjam</option>
                <option value="dikembalikan" {{ old('status') == 'dikembalikan' ? 'selected' : '' }}>Dikembalikan</option>
            </select>
        </div>

        <div class="flex space-x-4">
            <button type="submit" 
                    class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                Simpan
            </button>
            <a href="{{ route('peminjaman.index') }}" 
               class="bg-gray-300 text-gray-700 px-4 py-2 rounded hover:bg-gray-400">
                Batal
            </a>
        </div>
    </form>
</div>
@endsection

