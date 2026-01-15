<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BarangController;
use App\Http\Controllers\PeminjamanController;
use Illuminate\Support\Facades\Route;

// API Documentation (OpenAPI JSON)
Route::get('/api-docs.json', [\App\Http\Controllers\ApiDocsController::class, 'index']);

// Public routes (tanpa authentication)
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected routes (perlu authentication)
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);

    // Barang routes (admin only)
    Route::middleware('admin')->group(function () {
        Route::apiResource('barang', BarangController::class);
    });

    // Peminjaman routes (admin dan peminjam)
    Route::apiResource('peminjaman', PeminjamanController::class);
});

