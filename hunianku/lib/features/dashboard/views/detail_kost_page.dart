import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';

class DetailKostPage extends StatelessWidget {
  final KostModel kost;
  const DetailKostPage({super.key, required this.kost});

  final Color backgroundColor = const Color(0xFFEFEBE1); // Warna krem background atas
  final Color cardColor = const Color(0x80FBFBF9); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false, // Membiarkan konten memanjang sampai bawah layar
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16), // Memberi sedikit jarak dari status bar
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // --- HEADER (Tombol Back & Judul) ---
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        kost.namakost,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spasi kosong penyeimbang agar teks benar-benar di tengah
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- KONTEN BISA DI-SCROLL ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Kost
                      Center(
                        child: Container(
                          width: 220, // Lebar gambar disesuaikan
                          height: 260, // Tinggi gambar disesuaikan
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            // TODO: Nanti jika sudah punya gambar asli, aktifkan kode di bawah ini
                            // image: DecorationImage(
                            //   image: AssetImage('assets/kost_pink.png'),
                            //   fit: BoxFit.cover,
                            // ),
                          ),
                          child: const Icon(Icons.image, size: 60, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // jenis
                       _buildDetailItem('Jenis Kost:', kost.jenis),
                      const SizedBox(height: 16),
                      // Alamat
                      _buildDetailItem('Alamat:', kost.alamat),
                      const SizedBox(height: 16),
                      // Fasilitas
                      _buildDetailItem('Lokasi:',kost.lokasi),
                      const SizedBox(height: 16),
                      // Harga
                      _buildDetailItem('Harga:','Rp. ${kost.harga}/bulan'),
                      const SizedBox(height: 16),
                      // Fasilitas
                      _buildDetailItem('Fasilitas:', kost.daftarfasilitas),
                      const SizedBox(height: 16),
                      // Contact Person
                      _buildDetailItem('Contact Person:',kost.kontak ),
                      const SizedBox(height: 16),
                      // Deskripsi
                      _buildDetailItem('Deskripsi:',kost.deskripsi),
                      const SizedBox(height: 40), // Spasi bawah agar tidak mentok
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget bantuan agar tidak perlu menulis kode berulang untuk setiap judul & isi
  Widget _buildDetailItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4, // Memberikan jarak spasi antar baris agar nyaman dibaca
          ),
        ),
      ],
    );
  }
}