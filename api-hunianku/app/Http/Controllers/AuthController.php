<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Google_Client;
use GuzzleHttp\Client as GuzzleClient;

class AuthController extends Controller
{
    // 1. Fungsi Registrasi Biasa
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'role' => 'required|in:penghuni,pemilik'
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()], 400);
        }

        $user = User::create([
            'iduser' => 'USER-' . strtoupper(Str::random(8)),
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'data' => $user,
            'token' => $token
        ], 201);
    }

    // 2. Fungsi Login Biasa
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        // Cek apakah user ada dan password cocok
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau Password salah'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => $user,
            'token' => $token
        ], 200);
    }

    // 3. Fungsi Login via Google
    public function googleLogin(Request $request)
    {
        $request->validate(['id_token' => 'required']);

        try {
            // Decode JWT tanpa verifikasi online ke Google
            $parts = explode('.', $request->id_token);
            
            if (count($parts) !== 3) {
                return response()->json(['success' => false, 'message' => 'Token tidak valid'], 401);
            }

            $payload = json_decode(base64_decode(str_pad(
                strtr($parts[1], '-_', '+/'), 
                strlen($parts[1]) % 4 == 0 ? strlen($parts[1]) : strlen($parts[1]) + 4 - strlen($parts[1]) % 4, 
                '=', STR_PAD_RIGHT
            )), true);

            if (!$payload || !isset($payload['email'])) {
                return response()->json(['success' => false, 'message' => 'Token tidak valid'], 401);
            }

            // Cek token belum expired
            if ($payload['exp'] < time()) {
                return response()->json(['success' => false, 'message' => 'Token sudah expired'], 401);
            }

            $user = User::where('email', $payload['email'])->first();

            if (!$user) {
                $user = User::create([
                    'iduser'    => 'USER-' . strtoupper(Str::random(8)),
                    'nama'      => $payload['name'],
                    'email'     => $payload['email'],
                    'password'  => Hash::make(uniqid()),
                    'role'      => 'penghuni',
                    'google_id' => $payload['sub']
                ]);
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login Google berhasil',
                'data'    => $user,
                'token'   => $token
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }
}
