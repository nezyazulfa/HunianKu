import 'package:flutter/material.dart';
import 'package:hunianku/features/note/controllers/note_controller.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/features/note/model/note_model.dart';
import 'package:hunianku/services/kost_service.dart';
import 'package:hunianku/services/session_service.dart';

class TambahNotePage extends StatefulWidget {
  const TambahNotePage({super.key});

  @override
  State<TambahNotePage> createState() => _TambahNotePageState();
}

class _TambahNotePageState extends State<TambahNotePage> {
  final TextEditingController _noteController = TextEditingController();
  final NoteController _controller = NoteController();

  List<KostModel> _kumpulanKost = [];
  KostModel? _selectedKost;
  UserModel? _currentUser;

  final Color containerColor = const Color(0xFFFBFBF9); // Putih tulang
  final Color cardColor = Colors.white; // Putih bersih
  final Color primaryGreen = const Color(0xFF4A6525); // Hijau tombol

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // Fungsi untuk mengambil daftar kost dan user login di awal
  Future<void> _fetchInitialData() async {
    try {
      final listKost = await KostService().getAllKost();
      setState(() {
        _kumpulanKost = listKost;
      });
    } catch (e) {
      print('Gagal load kost: $e');
    }
    final id = await SessionService.getUserId();
    final nama = await SessionService.getNama();
    final role = await SessionService.getRole();
    if (id != null) {
      _currentUser = UserModel(
        iduser: id,
        nama: nama ?? 'User',
        email: '', password: '', role: role ?? 'penghuni',
      );
    }
  }

  // Fungsi untuk menampilkan Custom Searchable Dropdown (berupa Dialog)
  void _showKostDropdown() {
    List<KostModel> filteredList = List.from(_kumpulanKost);
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
                              .where((k) => k.namakost.toLowerCase().contains(value.toLowerCase())).toList();
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
                            title: Text(filteredList[index].namakost),
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
                                  _selectedKost?.namakost ?? 'Pilih Nama Kost',
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
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _controller.isLoading,
                    builder: (context, isLoading, child) {
                      return ElevatedButton(
                      onPressed: isLoading ? null :() async {
                        // Validasi sederhana
                        if (_selectedKost == null || _noteController.text.isEmpty || _currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pilih kost dan isi catatan terlebih dahulu!')),
                          );
                          return;
                        }

                        final now = DateTime.now();
                          final tanggalFormat = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                          final noteBaru = NoteModel(
                            idnote: 'NOTE-${now.millisecondsSinceEpoch}',
                            user: _currentUser,
                            kost: _selectedKost,
                            catatan: _noteController.text.trim(),
                            tanggal: tanggalFormat,
                          );
                          bool success = await _controller.tambahNote(noteBaru);

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Catatan berhasil disimpan!')),
                          );setState(() {
                            _selectedKost = null;
                            _noteController.clear();
                          });
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
                            : const Text('Simpan',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    );
                    }
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