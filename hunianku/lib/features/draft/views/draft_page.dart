import 'package:flutter/material.dart';
// Sesuaikan path import ini menuju file edit_kost_page.dart yang ada di folder kost_ku
import '../../kost_ku/views/edit_kost_page.dart'; 

class DraftPage extends StatelessWidget {
  const DraftPage({super.key});

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color cardColor = const Color(0xFFFBFBF9); 
  final Color buttonYellow = const Color(0xFFEBC144); 
  final Color buttonRed = const Color(0xFF6B1212); 
  final Color primaryGreen = const Color(0xFF4A6525); 

  // Dummy data sementara
  final List<Map<String, String>> dummyDraf = const [
    {
      'nama': 'Kost Bahagia',
      'alamat': 'Jl. Ciwaruga RT 01 RW 01',
      'jenis': 'Putri',
      'harga': 'RP. 600.000/bulan',
    },
    {
      'nama': 'Kost Bahagia',
      'alamat': 'Jl. Ciwaruga RT 01 RW 01',
      'jenis': 'Putri',
      'harga': 'RP. 600.000/bulan',
    },
    {
      'nama': 'Kost Bahagia',
      'alamat': 'Jl. Ciwaruga RT 01 RW 01',
      'jenis': 'Putri',
      'harga': 'RP. 600.000/bulan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false, 
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Judul Halaman
            const Text(
              'Draf',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Container Putih Lengkung
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 24.0, left: 24.0, right: 24.0, bottom: 100.0, 
                  ),
                  itemCount: dummyDraf.length,
                  itemBuilder: (context, index) {
                    return _buildDrafCard(context, dummyDraf[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU DRAF (DENGAN ICON EDIT, DELETE, & TOMBOL POSTING)
  Widget _buildDrafCard(BuildContext context, Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Kost
          Container(
            width: 120,
            height: 140, 
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.image, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          
          // Informasi Kost
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['nama']!,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  data['alamat']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['jenis']!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['harga']!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                
                // Baris Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tombol Edit
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditKostPage(initialData: data),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit, color: buttonYellow, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    
                    // Tombol Delete
                    IconButton(
                      onPressed: () {
                        _showDeleteDialog(context);
                      },
                      icon: Icon(Icons.delete, color: buttonRed, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Posting (Baru)
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Logika untuk memindahkan draf menjadi kost aktif (posting)
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        minimumSize: const Size(0, 32),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Posting', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

  // FUNGSI POP-UP DELETE
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 60),
              SizedBox(height: 16),
              Text(
                "Konfirmasi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Apakah anda yakin akan menghapus data ini?",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tidak", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Eksekusi hapus data MongoDB di sini
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B1212),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Ya", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}