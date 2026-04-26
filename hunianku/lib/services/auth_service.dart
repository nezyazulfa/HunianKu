import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../features/user/model/user_model.dart';

class AuthService {
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Inisialisasi Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '108664119568-lg90sg93ds646t5kccp78hi9vn0rh38h.apps.googleusercontent.com',
  );

  // Fungsi Bantuan untuk Mengekstrak Error dari Laravel
  String _parseErrorMessage(dynamic messageData) {
    if (messageData is String) {
      return messageData;
    } else if (messageData is Map) {
      return messageData.values.first[0].toString();
    }
    return 'Terjadi kesalahan tidak dikenal';
  }

  // 1. Fungsi Registrasi Biasa
  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _storage.write(key: 'auth_token', value: data['token']);
        return {'success': true, 'user': UserModel.fromMap(data['data'])};
      } else {
        return {
          'success': false,
          'message': _parseErrorMessage(data['message']),
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }

  // 2. Fungsi Login Biasa
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'auth_token', value: data['token']);
        return {'success': true, 'user': UserModel.fromMap(data['data'])};
      } else {
        return {
          'success': false,
          'message': _parseErrorMessage(data['message']),
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }

  // 3. Fungsi Login via Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'Login Google dibatalkan'};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {
          'success': false,
          'message': 'Gagal mendapatkan token pengenal dari Google',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_token': idToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'auth_token', value: data['token']);
        return {'success': true, 'user': UserModel.fromMap(data['data'])};
      } else {
        return {
          'success': false,
          'message': _parseErrorMessage(data['message']),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan sistem Google: $e',
      };
    }
  }

  // 4. Fungsi Logout
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _googleSignIn.signOut();
  }
}
