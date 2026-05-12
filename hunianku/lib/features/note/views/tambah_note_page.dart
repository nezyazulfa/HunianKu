import 'package:flutter/material.dart';

class TambahNotePage extends StatefulWidget {
  const TambahNotePage({super.key});

  @override
  State<TambahNotePage> createState() => _TambahNotePageState();
}

class _TambahNotePageState extends State<TambahNotePage> {
  final TextEditingController _noteController = TextEditingController();
  
  // Variabel untuk menyimpan kost yang dipilih
  String? _selectedKost;

  final Color containerColor = const Color(0xFFFBFBF9); // Putih tulang
  final Color cardColor = Colors.white; // Putih bersih
  final Color primaryGreen = const Color(0xFF4A6525); // Hijau tombol

  // TODO: Nanti ganti dummy ini dengan data yang di-fetch dari Controller
  final List<String> _kumpulanKost = [
    'Kost Bahagia',
    'Kost Gembira',
    'Kost Senang',
    'Kost Riang',
    'Kost Ceria',
  ];

  // Fungsi untuk menampilkan Custom Searchable Dropdown (berupa Dialog)
  void _showKostDropdown() {
    // Variabel lokal untuk menampung hasil pencarian di dalam dialog
    List<String> filteredList = List.from(_kumpulanKost);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Pilih Kost',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300, // Tinggi maksimal dropdown
                child: Column(
                  children: [
                    // --- Kolom Pencarian (Search...) ---
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          // Filter daftar kost berdasarkan teks yang diketik
                          filteredList = _kumpulanKost
                              .where((kost) => kost.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // --- Daftar Hasil Pencarian ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredList[index]),
                            onTap: () {
                              // Update state utama dan tutup dialog
                              setState(() {
                                _selectedKost = filteredList[index];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                // --- KARTU INPUT CATATAN ---
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
                        // --- DROPDOWN CUSTOM (Klik untuk memilih kost) ---
                        GestureDetector(
                          onTap: _showKostDropdown, // Memanggil fungsi dialog search
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedKost ?? 'Pilih Nama Kost',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: _selectedKost != null ? FontWeight.w800 : FontWeight.normal,
                                    color: _selectedKost != null ? Colors.black87 : Colors.grey,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.black87),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // --- INPUT CATATAN ---
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            maxLines: null,
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
                  padding: const EdgeInsets.only(bottom: 100.0, top: 8.0), 
                  child: ElevatedButton(
                    onPressed: () {
                      // Validasi sederhana
                      if (_selectedKost == null || _noteController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pilih kost dan isi catatan terlebih dahulu!')),
                        );
                        return;
                      }

                      // TODO: Panggil fungsi di Controller untuk menyimpan ke database.
                      // Contoh: _noteControllerKu.tambahNote(_selectedKost!, _noteController.text);
                      
                      // Feedback berhasil
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catatan berhasil disimpan!')),
                      );

                      // Bersihkan form setelah disave
                      setState(() {
                        _selectedKost = null;
                        _noteController.clear();
                      });
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
    );
  }
}