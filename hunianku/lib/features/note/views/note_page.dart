import 'package:flutter/material.dart';
import 'package:hunianku/features/note/views/edit_note_page.dart';
import 'package:hunianku/features/note/controllers/note_controller.dart';
import 'package:hunianku/features/note/model/note_model.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final NoteController _controller = NoteController();

  final Color containerColor = const Color(0xFFFBFBF9); // Putih tulang
  final Color cardColor = Colors.white;
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color buttonYellow = const Color(0xFFEBC144);
  final Color buttonRed = const Color(0xFF6B1212);

  @override
  void initState() {
    super.initState();
    _controller.featchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // HEADER JUDUL
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Notes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),

          // LIST CATATAN
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading)
                  return const Center(child: CircularProgressIndicator());

                return ValueListenableBuilder<List<NoteModel>>(
                  valueListenable: _controller.noteList,
                  builder: (context, notes, child) {
                    if (notes.isEmpty) {
                      return const Center(child: Text("Belum ada catatan."));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: 100.0,
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return _buildNoteCard(context, notes[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, NoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Kost
          Text(
            note.kost?.namakost ?? 'Kost Tidak Diketahui',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Isi Catatan
          Text(
            note.catatan,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Baris Bawah (Tanggal & Tombol Aksi)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Tanggal
              Text(
                note.tanggal,
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),

              // Tombol-tombol
              Row(
                children: [
                  // Icon Edit
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditNotePage(noteData: note, controller: _controller),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit, color: buttonYellow),
                    constraints:
                        const BoxConstraints(), // Memperkecil area klik bawaan
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  // Icon Delete
                  IconButton(
                    onPressed: () {
                      _showDeleteDialog(context, note);
                    },
                    icon: Icon(Icons.delete, color: buttonRed),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  // FUNGSI POP-UP DELETE
  void _showDeleteDialog(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Pakai dialogContext agar tidak bentrok
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column( // Gunakan const agar performa UI lebih ringan
            children: [
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
              onPressed: () => Navigator.pop(dialogContext), // Tutup pop-up
              child: const Text("Tidak", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                // 1. Tutup pop-up dialog terlebih dahulu
                Navigator.pop(dialogContext);
                
                // 2. Eksekusi hapus data MongoDB
                if (note.id != null) {
                  // Memanggil fungsi hapusNote dari controller yang sudah kita buat sebelumnya
                  bool success = await _controller.hapusNote(note.id!);
                  
                  // 3. Tampilkan pesan sukses di bawah layar
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Catatan berhasil dihapus!'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating, // Biar melayang keren
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B1212), // Warna merah gelap
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
