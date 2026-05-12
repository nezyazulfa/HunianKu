import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/dashboard/views/detail_kost_page.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  final Color containerColor = const Color(0xFFFBFBF9); 
  final Color cardColor = Colors.white; 
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color buttonRed = const Color(0xFF6B1212);

  // TODO: Nanti ganti dengan data KostModel dari database yang sudah difilter by Bookmark
  final List<KostModel> dummyBookmarks = const [
    
  ];

  @override
  Widget build(BuildContext context) {
    // Tanpa Scaffold karena ditempel di Dashboard
    return Column(
      children: [
        // --- HEADER JUDUL (Font disamakan dengan Tambah Notes) ---
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Bookmark',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),

        // --- KONTEN UTAMA ---
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 32.0,
                left: 24.0, 
                right: 24.0, 
                bottom: 100.0, // Jarak Navbar
              ),
              itemCount: dummyBookmarks.length,
              itemBuilder: (context, index) {
                final kost = dummyBookmarks[index];
                return _buildBookmarkCard(context, kost);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkCard(BuildContext context, KostModel kost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar Kost
          Container(
            width: 110,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.image, size: 40, color: Colors.grey), 
          ),
          const SizedBox(width: 16),
          
          // Detail & Tombol
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kost.namakost,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  kost.alamat,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEBE1), // Krem background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kost.jenis,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp. ${kost.harga}/bulan',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                
                // Row Tombol Hapus & Lihat Detail
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Logika Hapus Bookmark
                      },
                      icon: Icon(Icons.delete, color: buttonRed, size: 24),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 8),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailKostPage(kost: kost),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        minimumSize: const Size(0, 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Lihat Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}