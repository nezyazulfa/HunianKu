import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hunianku/features/user/model/user_model.dart';
import 'package:hunianku/services/mongo_service.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final MongoService _mongo = MongoService();
  final String _collectionName = 'user';

  // Inisialisasi Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '108664119568-lg90sg93ds646t5kccp78hi9vn0rh38h.apps.googleusercontent.com',
  );

  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Ubah string ke bytes
    var digest = sha256.convert(bytes); // Lakukan hashing SHA-256
    return digest.toString();
  }

  // 1. Fungsi Registrasi Biasa
  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      final cleanEmail = email.trim();
      
      // Validasi: Apakah email sudah terdaftar di MongoDB?
      final existingUser = await collection.findOne(where.eq('email', cleanEmail));
      if (existingUser != null) {
        return {'success': false, 'message': 'Email sudah terdaftar. Silakan login.'};
      }

      final String generatedIdUser = 'USR-${DateTime.now().millisecondsSinceEpoch}';
      final String hashedPassword = _hashPassword(password);

      // Jika aman, buat struktur data baru
      final newUser = {
        '_id': ObjectId(),
        'iduser': generatedIdUser,
        'nama': nama,
        'email': cleanEmail,
        'password': hashedPassword,
        'role': role,
        'auth_provider': 'manual',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Simpan ke database
      await collection.insertOne(newUser);
      
      // Simpan ID sebagai token di memori HP
      await _storage.write(key: 'auth_token', value: (newUser['_id']as ObjectId).oid);
      return {'success': true, 'user': UserModel.fromMap(newUser)};
    } catch (e) {
      return {'success': false, 'message': 'Gagal registrasi: $e'};
    }
  }

  // 2. Fungsi Login Biasa
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      final cleanEmail = email.trim();
      final hashedPassword = _hashPassword(password);

      // Cari data yang email DAN password-nya cocok
      final user = await collection.findOne(where.eq('email', cleanEmail).eq('password', hashedPassword));

      if (user != null) {
        // Jika ketemu, simpan token dan masuk
        await _storage.write(key: 'auth_token', value: (user['_id'] as ObjectId).oid);
        return {'success': true, 'user': UserModel.fromMap(user)};
      } else {
        return {'success': false, 'message': 'Email atau password salah.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal login: $e'};
    }
  }

  // 3. Fungsi Login via Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'Login Google dibatalkan'};
      }

      final collection = await _mongo.getCollection(_collectionName);
      
      // Cek apakah email dari akun Google ini sudah ada di MongoDB
      var user = await collection.findOne(where.eq('email', googleUser.email));
      
      // Jika belum ada (Berarti Pengguna Baru), kita otomatis daftarkan!
      if (user != null)
      {
        await _storage.write(key: 'auth_token', value: (user['_id'] as ObjectId).oid);
        return {'success': true, 'user': UserModel.fromMap(user), 'needs_role': false};
      }    
      else{
        return {
          'success': false, 
          'message': 'Akun baru. Silakan pilih role Anda.',
          'needs_role': true,           
          'email': googleUser.email,
          'nama': googleUser.displayName ?? 'Pengguna Google'
        };
      } 
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem Google: $e'};
    }
  }

  // 4. Fungsi Lengkapi Registrasi Google (Pilih Role)
  Future<Map<String, dynamic>> completeGoogleRegistration({
    required String email,
    required String nama,
    required String role,
  }) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      final String generatedIdUser = 'GLG-${DateTime.now().millisecondsSinceEpoch}';
      
      final newUser = {
        '_id': ObjectId(),
        'iduser': generatedIdUser,
        'nama': nama,
        'email': email,
        'password': '', // Kosongkan
        'role': role, 
        'auth_provider': 'google',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await collection.insertOne(newUser);
      await _storage.write(key: 'auth_token', value: (newUser['_id'] as ObjectId).oid);
      return {'success': true, 'user': UserModel.fromMap(newUser)};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menyimpan role Google: $e'};
    }
  }

  // 5. Fungsi Logout
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _googleSignIn.signOut();
  }
}
