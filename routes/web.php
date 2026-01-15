<?php

use Illuminate\Support\Facades\Route;

// Redirect root ke dokumentasi API
Route::get('/', function () {
    return redirect('/api/documentation');
});

// API Documentation Routes
Route::get('/api/documentation', function () {
    return view('api-documentation');
})->name('api.documentation');

Route::get('/api/redoc', function () {
    return view('api-redoc');
})->name('api.redoc');
