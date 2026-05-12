import 'package:flutter/material.dart';

class EditNotePage extends StatefulWidget {
  // Menerima data awal dari catatan yang ingin diedit
  final Map<String, String> noteData;

  const EditNotePage({super.key, required this.noteData});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _noteController;
  
  final Color backgroundColor = const Color(0xFFEFEBE1); // Krem background atas
  final Color containerColor = const Color(0xFFFBFBF9); // Putih tulang background melengkung
  final Color cardColor = Colors.white; // Putih bersih untuk kotak input
  final Color primaryGreen = const Color(0xFF4A6525); // Hijau untuk tombol

  @override
  void initState() {
    super.initState();
    // Mengisi controller dengan isi catatan lama yang diterima dari parameter
    _noteController = TextEditingController(text: widget.noteData['note']);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- HEADER DENGAN TOMBOL BACK ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Edit Notes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                    // --- KARTU INPUT CATATAN (Sesuai desain gambar) ---
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
                            // Nama Kost (Statis & Tidak dapat diubah sesuai permintaan)
                            Text(
                              widget.noteData['kost'] ?? 'Kost Bahagia',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Field Edit Isi Catatan
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  hintText: 'Edit catatanmu di sini...',
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
                      padding: const EdgeInsets.only(bottom: 40.0, top: 8.0), 
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Panggil fungsi update di Controller untuk mengirim perubahan ke database
                          // Contoh: _noteController.updateNote(widget.noteData['id'], _noteController.text);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Catatan berhasil diperbarui!')),
                          );
                          
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
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
        ),
      ),
    );
  }
}