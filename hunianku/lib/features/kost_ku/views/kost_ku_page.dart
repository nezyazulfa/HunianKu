import 'package:flutter/material.dart';
import 'edit_kost_page.dart'; 
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/kost_ku/controllers/kost_ku_controller.dart';

class KostKuPage extends StatefulWidget {
  const KostKuPage({super.key});

  @override
  State<KostKuPage> createState() => _KostKuPageState();
}

class _KostKuPageState extends State<KostKuPage> {
  final KostKuController _controller = KostKuController();

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color cardColor = const Color(0xFFFBFBF9); 
  final Color buttonYellow = const Color(0xFFEBC144); 
  final Color buttonRed = const Color(0xFF6B1212); 

  @override
  void initState() {
    super.initState();
    _controller.fetchKostKu();
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
            const Text(
              'Kost Ku',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

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
                child: ValueListenableBuilder<bool>(
                  valueListenable: _controller.isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ValueListenableBuilder<List<KostModel>>(
                      valueListenable: _controller.kostKuList,
                      builder: (context, kostKu, child) {
                        if (kostKu.isEmpty) {
                          return const Center(child: Text("Anda belum memiliki kost.", style: TextStyle(color: Colors.grey)));
                        }

                        // Menggunakan RefreshIndicator agar pemilik bisa me-refresh data
                        return RefreshIndicator(
                          onRefresh: () async {
                            await _controller.fetchKostKu();
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              top: 24.0, left: 24.0, right: 24.0, bottom: 100.0, 
                            ),
                            itemCount: kostKu.length,
                            itemBuilder: (context, index) {
                              return _buildKostKuCard(context, kostKu[index]);
                            },
                          ),
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

  // WIDGET CARD (Menerima parameter KostModel)
  Widget _buildKostKuCard(BuildContext context, KostModel kost) {
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
                  kost.namakost,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  kost.alamat,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kost.jenis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kost.harga,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // Bawa data kost utuh ke halaman Edit
                            builder: (context) => EditKostPage(kostData: kost, initialData: {}, isDraft: false,),
                          ),
                        ).then((_) {
                          // Refresh data saat kembali dari halaman edit
                          _controller.fetchKostKu();
                        });
                      },
                      icon: Icon(Icons.edit, color: buttonYellow, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        _showDeleteDialog(context, kost.idkost);
                      },
                      icon: Icon(Icons.delete, color: buttonRed, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

  void _showDeleteDialog(BuildContext context, String idkost) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 60),
              SizedBox(height: 16),
              Text(
                "Hapus Kost?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Data kost ini akan dihapus permanen dari server. Tindakan ini tidak bisa dibatalkan.",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup dialog
                // Panggil controller untuk hapus dari database cloud
                _controller.hapusKost(context, idkost); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Ya, Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}