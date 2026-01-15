@extends('layouts.app')

@section('title', 'Tambah Barang')

@section('content')
<div class="max-w-2xl mx-auto bg-white rounded-lg shadow-md p-6">
    <h2 class="text-2xl font-bold mb-6">Tambah Barang</h2>
    
    <form method="POST" action="{{ route('barang.store') }}">
        @csrf
        
        <div class="mb-4">
            <label for="nama_barang" class="block text-gray-700 font-medium mb-2">Nama Barang *</label>
            <input type="text" 
                   id="nama_barang" 
                   name="nama_barang" 
                   value="{{ old('nama_barang') }}"
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                   required>
        </div>

        <div class="mb-4">
            <label for="stok" class="block text-gray-700 font-medium mb-2">Stok *</label>
            <input type="number" 
                   id="stok" 
                   name="stok" 
                   value="{{ old('stok') }}"
                   min="0"
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                   required>
        </div>

        <div class="mb-4">
            <label for="keterangan" class="block text-gray-700 font-medium mb-2">Keterangan</label>
            <textarea id="keterangan" 
                      name="keterangan" 
                      rows="3"
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">{{ old('keterangan') }}</textarea>
        </div>

        <div class="flex space-x-4">
            <button type="submit" 
                    class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                Simpan
            </button>
            <a href="{{ route('barang.index') }}" 
               class="bg-gray-300 text-gray-700 px-4 py-2 rounded hover:bg-gray-400">
                Batal
            </a>
        </div>
    </form>
</div>
@endsection

