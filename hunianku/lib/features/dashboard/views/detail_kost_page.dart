import 'package:flutter/material.dart';

class DetailKostPage extends StatelessWidget {
  // Menerima data kost yang diklik dari halaman sebelumnya
  final Map<String, String> kostData;

  const DetailKostPage({super.key, required this.kostData});

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
                        kostData['nama'] ?? 'Detail Kost',
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

                      // Alamat
                      _buildDetailItem(
                        'Alamat:',
                        kostData['alamat_lengkap'] ?? 
                        'Jl. Ciwaruga RT 01 RW 01, Desa Ciwaruga, Kecamatan Parongpong, Kabupaten Bandung Barat. (https.googlemaps.KostBahagia)',
                      ),
                      const SizedBox(height: 16),

                      // Fasilitas
                      _buildDetailItem(
                        'Fasilitas:',
                        kostData['fasilitas'] ?? 
                        'Khusus putri\nKamar mandi luar\nDapur bersama\nCCTV\nWifi\nMeja\nKasur\nLemari',
                      ),
                      const SizedBox(height: 16),

                      // Harga
                      _buildDetailItem(
                        'Harga:',
                        kostData['harga'] ?? 'Rp. 600.000/bulan',
                      ),
                      const SizedBox(height: 16),

                      // Contact Person
                      _buildDetailItem(
                        'Contact Person:',
                        kostData['kontak'] ?? '08123456789',
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      _buildDetailItem(
                        'Deskripsi:',
                        kostData['deskripsi'] ?? 'Gerbang dibuka 24 jam',
                      ),
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