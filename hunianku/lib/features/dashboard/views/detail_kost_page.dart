import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';

class DetailKostPage extends StatefulWidget {
  final KostModel kost;
  const DetailKostPage({super.key, required this.kost});

  @override
  State<DetailKostPage> createState() => _DetailKostPageState();
}

class _DetailKostPageState extends State<DetailKostPage> {
  // Variabel untuk menyimpan status apakah kost ini di-bookmark atau tidak
  bool isBookmarked = false;

  final Color backgroundColor = const Color(0xFFEFEBE1); // Warna krem background atas
  final Color cardColor = const Color(0x80FBFBF9); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false, 
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16), 
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // --- HEADER (Tombol Back, Judul, & Tombol Bintang) ---
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
                        widget.kost.namakost,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // --- TOMBOL BOOKMARK BINTANG DI KANAN ATAS ---
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.star : Icons.star_border,
                        color: const Color(0xFFEBC144), // Kuning mustard
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          isBookmarked = !isBookmarked; // Toggle status bookmark
                        });
                        
                        // Menampilkan notifikasi kecil di bawah
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBookmarked 
                                ? 'Ditambahkan ke Bookmark' 
                                : 'Dihapus dari Bookmark'
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );

                        // TODO: Panggil fungsi Controller di sini untuk menyimpan/menghapus bookmark di Database MongoDB
                      },
                    ),
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
                          width: 220, 
                          height: 260, 
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
                          ),
                          child: const Icon(Icons.image, size: 60, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildDetailItem('Jenis Kost:', widget.kost.jenis),
                      const SizedBox(height: 16),
                      _buildDetailItem('Alamat:', widget.kost.alamat),
                      const SizedBox(height: 16),
                      _buildDetailItem('Lokasi:', widget.kost.lokasi),
                      const SizedBox(height: 16),
                      _buildDetailItem('Harga:', 'Rp. ${widget.kost.harga}/bulan'),
                      const SizedBox(height: 16),
                      _buildDetailItem('Fasilitas:', widget.kost.daftarfasilitas),
                      const SizedBox(height: 16),
                      _buildDetailItem('Contact Person:', widget.kost.kontak),
                      const SizedBox(height: 16),
                      _buildDetailItem('Deskripsi:', widget.kost.deskripsi),
                      const SizedBox(height: 40), 
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
            height: 1.4, 
          ),
        ),
      ],
    );
  }
}