import 'package:flutter/material.dart';
import 'package:hunianku/services/auth_service.dart';
import 'package:hunianku/features/dashboard/views/dashboard_page.dart';
import 'package:hunianku/services/session_service.dart';
import 'package:hunianku/features/auth/views/login_page.dart';

class AuthController {
  final AuthService _authService = AuthService();

  // ValueNotifier untuk mengatur state loading secara reaktif
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      _showMessage(context, "Email dan password tidak boleh kosong!");
      return;
    }

    isLoading.value = true;

    final result = await _authService.login(email: email, password: password);

    isLoading.value = false;

    if (result['success']) {
      await SessionService.saveSession(result['user']);
      _showMessage(
        context,
        "Login Berhasil! Selamat datang ${result['user'].nama}",
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      _showMessage(context, result['message'], isError: true);
    }
  }

  Future<void> register(
    BuildContext context,
    String nama,
    String email,
    String password,
    String role,
  ) async {
    if (nama.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty) {
      _showMessage(context, "Semua kolom wajib diisi!");
      return;
    }

    isLoading.value = true;

    final result = await _authService.register(
      nama: nama,
      email: email,
      password: password,
      role: role,
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
      await SessionService.saveSession(result['user']);
      _showMessage(
        context,
        "Login Google Berhasil! Hai ${result['user'].nama}",
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (result['needs_role'] == true) {
      // KONDISI 2: PENGGUNA BARU (Minta Role Dulu)
      _showRoleSelectionDialog(context, result['email'], result['nama']);
    } else {
      if (result['message'] != 'Login Google dibatalkan') {
        _showMessage(context, result['message'], isError: true);
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    isLoading.value = true;

    try {
      // 1. Hapus token/cache dari database lokal (termasuk Google Sign Out)
      await _authService.logout();

      // 2. Bersihkan data user dari Session
      await SessionService.clearSession(); // Pastikan fungsi clearSession() sudah ada di SessionService ya!

      isLoading.value = false;

      // 3. Arahkan kembali ke halaman Login dan hapus semua riwayat halaman (Biar tidak bisa di-Back)
      if (context.mounted) {
        _showMessage(context, "Anda berhasil keluar.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) =>
              false, // false artinya buang semua route sebelumnya
        );
      }
    } catch (e) {
      isLoading.value = false;
      if (context.mounted) {
        _showMessage(context, "Gagal keluar: $e", isError: true);
      }
    }
  }

  void _showRoleSelectionDialog(
    BuildContext context,
    String email,
    String nama,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan mengetuk luar area
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Pilih Peran Anda'),
          content: const Text(
            'Apakah Anda akan mendaftar sebagai Pencari Kos atau Pemilik Kos?',
          ),
          actions: [
            TextButton(
              onPressed: () => _finishGoogleRegistration(
                context,
                dialogContext,
                email,
                nama,
                'penghuni',
              ),
              child: const Text('Penghuni'),
            ),
            ElevatedButton(
              onPressed: () => _finishGoogleRegistration(
                context,
                dialogContext,
                email,
                nama,
                'pemilik',
              ),
              child: const Text('Pemilik Kos'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi baru untuk mengirim data Role yang dipilih ke Service
  Future<void> _finishGoogleRegistration(
    BuildContext context,
    BuildContext dialogContext,
    String email,
    String nama,
    String role,
  ) async {
    Navigator.of(dialogContext).pop(); // Tutup dialognya

    isLoading.value = true;
    final result = await _authService.completeGoogleRegistration(
      email: email,
      nama: nama,
      role: role,
    );
    isLoading.value = false;

    if (result['success']) {
      await SessionService.saveSession(result['user']);
      _showMessage(
        context,
        "Registrasi Google Berhasil! Hai ${result['user'].nama}",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      _showMessage(context, result['message'], isError: true);
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
