import 'package:flutter/material.dart';

class TambahNotePage extends StatefulWidget {
  const TambahNotePage({super.key});

  @override
  State<TambahNotePage> createState() => _TambahNotePageState();
}

class _TambahNotePageState extends State<TambahNotePage> {
  final TextEditingController _noteController = TextEditingController();
  
  final Color containerColor = const Color(0xFFFBFBF9); // Putih tulang untuk background melengkung
  final Color cardColor = Colors.white; // Putih bersih untuk kotak input
  final Color primaryGreen = const Color(0xFF4A6525); // Hijau untuk tombol

  @override
  Widget build(BuildContext context) {
    // Tidak menggunakan Scaffold karena sudah menempel di DashboardPage
    return Column(
      children: [
        // --- HEADER JUDUL ---
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Tambah Notes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),

        // --- KONTEN UTAMA (Latar Putih Tulang Melengkung) ---
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
            child: Column(
              children: [
                // --- KARTU INPUT CATATAN (Floating Card) ---
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kost Bahagia', // Nama Kost
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            maxLines: null, // Agar teks bisa turun ke baris baru otomatis
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: 'Tulis catatanmu di sini...',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 14, 
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- TOMBOL SIMPAN ---
                Padding(
                  // Jarak bottom 100 penting agar tombol tidak tertutup oleh Navbar hijau di bawah
                  padding: const EdgeInsets.only(bottom: 100.0, top: 8.0), 
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Tambahkan logika untuk menyimpan catatan ke database
                      // Setelah simpan, bisa dikosongkan form-nya atau pindah tab
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      // Mengatur lebar tombol agar tidak full layar (seperti di desain)
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}