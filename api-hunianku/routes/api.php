<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

// Jalur yang bisa diakses tanpa perlu login
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/login/google', [AuthController::class, 'googleLogin']);

// Contoh jalur yang dilindungi (Harus bawa Token saat request)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profil-saya', function (Request $request) {
        return $request->user();
    });
});
