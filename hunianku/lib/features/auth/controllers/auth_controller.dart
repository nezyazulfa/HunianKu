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
      showMessage(context, "Email dan password tidak boleh kosong!", isError: true);
      return;
    }

    isLoading.value = true;

    try {
      final result = await _authService.login(email: email, password: password);
      isLoading.value = false;

      if (!context.mounted) return;

      if (result['success']) {
        await SessionService.saveSession(result['user']);
        showMessage(
          context,
          "Login Berhasil! Selamat datang ${result['user'].nama}",
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else {
        showMessage(context, result['message'], isError: true);
      }
    } catch (e) {
      isLoading.value = false;
      if (!context.mounted) return;
      showMessage(
        context,
        "Gagal terhubung. Pastikan Anda tidak berada di area blank spot.",
        isError: true,
      );
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
      showMessage(context, "Semua kolom wajib diisi!", isError: true);
      return;
    }

    isLoading.value = true;

    try {
      final result = await _authService.register(
        nama: nama,
        email: email,
        password: password,
        role: role,
      );

      isLoading.value = false;
      if (!context.mounted) return;

      if (result['success']) {
        if (result['user'] != null) {
          await SessionService.saveSession(result['user']);
        }

        showMessage(context, "Registrasi Berhasil!");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      } else {
        showMessage(context, result['message'], isError: true);
      }
    } catch (e) {
      isLoading.value = false;
      if (!context.mounted) return;
      showMessage(
        context,
        "Registrasi gagal. Periksa kembali koneksi internet Anda.",
        isError: true,
      );
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    isLoading.value = true;

    try {
      final result = await _authService.loginWithGoogle();

      isLoading.value = false;
      if (!context.mounted) return;

      if (result['success']) {
        await SessionService.saveSession(result['user']);
        showMessage(
          context,
          "Login Google Berhasil! Hai ${result['user'].nama}",
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      } else if (result['needs_role'] == true) {
        // KONDISI 2: PENGGUNA BARU (Minta Role Dulu)
        _showRoleSelectionDialog(context, result['email'], result['nama']);
      } else {
        if (result['message'] != 'Login Google dibatalkan') {
          showMessage(context, result['message'], isError: true);
        }
      }
    } catch (e) {
      isLoading.value = false;
      if (!context.mounted) return;
      showMessage(
        context,
        "Gagal masuk dengan Google akibat gangguan jaringan.",
        isError: true,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    isLoading.value = true;

    try {
      // 1. Hapus token/cache dari database lokal
      await _authService.logout();
      // 2. Bersihkan data user dari Session
      await SessionService.clearSession(); 

      isLoading.value = false;

      // 3. Arahkan kembali ke halaman Login
      if (context.mounted) {
        showMessage(context, "Anda berhasil keluar.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false, 
        );
      }
    } catch (e) {
      isLoading.value = false;
      if (context.mounted) {
        showMessage(context, "Gagal keluar, periksa koneksi Anda.", isError: true);
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
      barrierDismissible: false,
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

  Future<void> _finishGoogleRegistration(
    BuildContext context,
    BuildContext dialogContext,
    String email,
    String nama,
    String role,
  ) async {
    Navigator.of(dialogContext).pop(); // Tutup dialognya

    isLoading.value = true;
    try {
      final result = await _authService.completeGoogleRegistration(
        email: email,
        nama: nama,
        role: role,
      );
      isLoading.value = false;

      if (!context.mounted) return;

      if (result['success']) {
        await SessionService.saveSession(result['user']);
        showMessage(
          context,
          "Registrasi Google Berhasil! Hai ${result['user'].nama}",
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      } else {
        showMessage(context, result['message'], isError: true);
      }
    } catch (e) {
      isLoading.value = false;
      if (!context.mounted) return;
      showMessage(
        context,
        "Gagal menyimpan data peran. Sinyal mungkin terputus.",
        isError: true,
      );
    }
  }

  void showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    String displayMessage = message;
    if (message.contains('PlatformException') || message.contains('network_error')) {
      displayMessage = "Gagal terhubung. Pastikan internet Anda stabil.";
    }

    // Mengambil overlay dari layar saat ini
    final overlay = Overlay.of(context);
    
    // Membuat widget melayang (OverlayEntry)
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Posisikan di atas, ditambah jarak aman dari status bar (poni HP)
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent, // Material transparan agar tidak ada background aneh
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white, // Latar putih sesuai request
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              displayMessage,
              style: TextStyle(
                color: isError ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Hapus pesan setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}