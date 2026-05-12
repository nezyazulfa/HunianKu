import 'package:flutter/material.dart';
import 'package:hunianku/features/note/views/edit_note_page.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  final Color containerColor = const Color(0xFFFBFBF9); // Putih tulang
  final Color cardColor = Colors.white; 
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color buttonYellow = const Color(0xFFEBC144);
  final Color buttonRed = const Color(0xFF6B1212);

  // Data dummy sementara
  final List<Map<String, String>> dummyNotes = const [
    {
      'kost': 'Kost Bahagia',
      'note': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'date': '12.00 - 5 Januari 2005',
    },
    {
      'kost': 'Kost Gembira',
      'note': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'date': '12.00 - 5 Mei 2005',
    },
    {
      'kost': 'Kost Senang',
      'note': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'date': '12.00 - 5 Januari 2015',
    },
  ];

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
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 24.0, 
                right: 24.0, 
                bottom: 100.0, // Jarak agar tidak tertutup Navbar
              ),
              itemCount: dummyNotes.length,
              itemBuilder: (context, index) {
                return _buildNoteCard(context, dummyNotes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Map<String, String> noteData) {
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
            noteData['kost']!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Isi Catatan
          Text(
            noteData['note']!,
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
                noteData['date']!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                ),
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
                          builder: (context) => EditNotePage(noteData: noteData),
                          ),
                      );
                    },
                    icon: Icon(Icons.edit, color: buttonYellow),
                    constraints: const BoxConstraints(), // Memperkecil area klik bawaan
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  // Icon Delete
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete, color: buttonRed),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Posting
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Posting',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}