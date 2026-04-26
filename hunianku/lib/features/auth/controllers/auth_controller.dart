import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();
  
  // ValueNotifier untuk mengatur state loading secara reaktif
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> login(BuildContext context, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showMessage(context, "Email dan password tidak boleh kosong!");
      return;
    }

    isLoading.value = true; 
    
    final result = await _authService.login(email: email, password: password);
    
    isLoading.value = false; 

    if (result['success']) {
      _showMessage(context, "Login Berhasil! Selamat datang ${result['user'].nama}");
      // TODO: Navigasi ke halaman utama (Home)
      // Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showMessage(context, result['message'], isError: true);
    }
  }

  Future<void> register(BuildContext context, String nama, String email, String password, String role) async {
    if (nama.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty) {
      _showMessage(context, "Semua kolom wajib diisi!");
      return;
    }

    isLoading.value = true;

    final result = await _authService.register(
      nama: nama, 
      email: email, 
      password: password, 
      role: role
    );

    isLoading.value = false;

    if (result['success']) {
      _showMessage(context, "Registrasi Berhasil!");
      // TODO: Navigasi ke halaman utama
    } else {
      _showMessage(context, result['message'], isError: true);
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    isLoading.value = true;
    
    final result = await _authService.loginWithGoogle();
    
    isLoading.value = false;

    if (result['success']) {
      _showMessage(context, "Login Google Berhasil! Hai ${result['user'].nama}");
      // TODO: Navigasi ke halaman utama
    } else {
      if (result['message'] != 'Login Google dibatalkan') {
        _showMessage(context, result['message'], isError: true);
      }
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}