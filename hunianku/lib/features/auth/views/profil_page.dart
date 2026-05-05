import 'package:flutter/material.dart';
import 'package:hunianku/services/session_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Memuat...';
  String _userRole = '';

  // Warna sesuai desain
  final Color backgroundColor = const Color(0xFFEFEBE1); // Krem terang
  final Color cardColor = const Color(0xFFFBFBF9); // Putih tulang
  final Color buttonRed = const Color(0xFF6B1212); // Merah marun untuk tombol keluar
  final Color avatarPlaceholderColor = const Color(0xFFBCAAA4); // Warna abu-abu kecoklatan untuk lingkaran

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Mengambil nama dan role dari session saat halaman dimuat
  Future<void> _loadUserData() async {
    final nama = await SessionService.getNama() ?? 'Nama User';
    final role = await SessionService.getRole() ?? 'penghuni';
    
    setState(() {
      _userName = nama;
      // Mengubah huruf pertama role menjadi kapital agar rapi (cth: "pemilik" -> "Pemilik Kost")
      if (role == 'pemilik') {
        _userRole = 'Pemilik Kost';
      } else {
        _userRole = 'Penghuni Kost';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            // --- JUDUL HALAMAN ---
            const Text(
              'Saya',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold, // Pakai bold standar, bisa disesuaikan kalau punya custom font
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // --- CARD PROFIL DENGAN AVATAR MENGAMBANG ---
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // 1. Card Putih (Diberi margin top agar posisinya turun ke bawah)
                Container(
                  margin: const EdgeInsets.only(
                    top: 50, // Angka ini sama dengan radius avatar agar tepat di tengah
                    left: 40,
                    right: 40,
                  ),
                  padding: const EdgeInsets.only(
                    top: 70, // Padding atas besar untuk memberi ruang bagi avatar
                    bottom: 40,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userRole,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // 2. Lingkaran Avatar (Ditumpuk di atas Card)
                CircleAvatar(
                  radius: 50, // Ukuran lingkaran
                  backgroundColor: avatarPlaceholderColor,
                  // Kalau nanti mau pakai foto profil dari database/asset, aktifkan ini:
                  // backgroundImage: AssetImage('assets/default_profile.png'), 
                ),
              ],
            ),

            // --- SPACER ---
            // Spacer ini akan mendorong tombol "Keluar" terus ke bagian paling bawah layar
            const Spacer(),

            // --- TOMBOL KELUAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Logika Logout
                  // 1. Panggil SessionService.clearSession()
                  // 2. Lempar user kembali ke halaman Login pakai Navigator.pushReplacement
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50), // Lebar penuh, tinggi 50
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Jarak tambahan di bawah tombol agar tidak tertutup oleh Bottom Navigation Bar
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }
}