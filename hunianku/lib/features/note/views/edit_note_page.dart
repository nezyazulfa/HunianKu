import 'package:flutter/material.dart';
import 'package:hunianku/features/note/model/note_model.dart';
import 'package:hunianku/features/note/controllers/note_controller.dart';

class EditNotePage extends StatefulWidget {
  final NoteModel noteData;
  final NoteController controller;

  const EditNotePage({super.key, required this.noteData, required this.controller});

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
    // Mengisi controller dengan data catatan yang sudah ada
    _noteController = TextEditingController(text: widget.noteData.catatan);
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
                            Text(
                              widget.noteData.kost?.namakost ?? 'Kost Bahagia',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                      child: ValueListenableBuilder<bool>(
                        valueListenable: widget.controller.isLoading,
                        builder: (context, isLoading, child) {
                          return ElevatedButton(
                          onPressed: isLoading ? null: () async {
                            final updatedNote = NoteModel(
                                id: widget.noteData.id, // Pertahankan ID asli
                                idnote: widget.noteData.idnote,
                                user: widget.noteData.user,
                                kost: widget.noteData.kost,
                                tanggal: widget.noteData.tanggal, // Tetap gunakan tanggal lama atau ubah jadi waktu sekarang
                                catatan: _noteController.text.trim(), // Isi teks terbaru
                              );
                              // 2. Lempar ke controller
                              bool success = await widget.controller.simpanEditNote(updatedNote);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catatan berhasil diperbarui!')));
                                Navigator.pop(context); // Kembali ke halaman list note
                              }
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
                        child: isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        );
                        },
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