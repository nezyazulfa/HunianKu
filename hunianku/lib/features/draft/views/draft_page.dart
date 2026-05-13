import 'package:flutter/material.dart';
import '../../kost_ku/views/edit_kost_page.dart'; 
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/draft/controllers/draft_controller.dart'; 

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  final DraftController _controller = DraftController();

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color cardColor = const Color(0xFFFBFBF9); 
  final Color buttonYellow = const Color(0xFFEBC144); 
  final Color buttonRed = const Color(0xFF6B1212); 
  final Color primaryGreen = const Color(0xFF4A6525);
  
  Map<String, String>? get dataForEdit => null; 

  @override
  void initState() {
    super.initState();
    // Ambil data draf saat halaman pertama kali dibuka
    _controller.fetchDrafts();
  }

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
                // Menggunakan ValueListenableBuilder untuk reaktivitas Controller
                child: ValueListenableBuilder<bool>(
                  valueListenable: _controller.isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) {
                      return Center(child: CircularProgressIndicator(color: primaryGreen));
                    }

                    return ValueListenableBuilder<List<KostModel>>(
                      valueListenable: _controller.draftList,
                      builder: (context, drafts, child) {
                        if (drafts.isEmpty) {
                          return const Center(
                            child: Text('Belum ada draf kost yang disimpan.', style: TextStyle(color: Colors.grey)),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 24.0, left: 24.0, right: 24.0, bottom: 100.0, 
                          ),
                          itemCount: drafts.length,
                          itemBuilder: (context, index) {
                            return _buildDrafCard(context, drafts[index]);
                          },
                        );
                      }
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU DRAF MENERIMA PARAMETER KostModel
  Widget _buildDrafCard(BuildContext context, KostModel kost) {
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
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kost.namakost, // Mengambil data asli
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  kost.alamat, // Mengambil data asli
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kost.jenis, // Mengambil data asli
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kost.harga, // Mengambil data asli
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                
                // Baris Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // TOMBOL EDIT
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditKostPage(initialData: dataForEdit ?? {}, kostData: kost, isDraft: true,),
                          ),
                        ).then((_) {
                          // Refresh data saat kembali dari halaman edit (jaga-jaga jika di-save)
                          _controller.fetchDrafts();
                        });
                      },
                      icon: Icon(Icons.edit, color: buttonYellow, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    
                    // TOMBOL DELETE
                    IconButton(
                      onPressed: () {
                        _showDeleteDialog(context, kost.idkost);
                      },
                      icon: Icon(Icons.delete, color: buttonRed, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),

                    // TOMBOL POSTING
                    ElevatedButton(
                      onPressed: () {
                        _showPostingDialog(context, kost);
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
  void _showDeleteDialog(BuildContext context, String idkost) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Gunakan nama variabel beda untuk konteks dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Tidak", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup dialog
                _controller.hapusDraft(context, idkost); // Panggil fungsi hapus di Controller
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

  // FUNGSI POP-UP VALIDASI POSTING (UNGGAH)
  void _showPostingDialog(BuildContext context, KostModel kost) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Icon(Icons.cloud_upload_rounded, color: primaryGreen, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Posting Kost?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Pastikan semua data (termasuk harga dan fasilitas) sudah benar. Lanjutkan mempublikasikan kost ini?",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // View menutup popup
              child: const Text("Periksa Lagi", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // View menutup popup
                _controller.postingDraft(context, kost); // View mengutus Controller untuk posting data
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Ya, Posting", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}