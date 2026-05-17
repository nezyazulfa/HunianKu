import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/bookmark/model/bookmark_model.dart';
import 'package:hunianku/features/dashboard/views/detail_kost_page.dart';
import 'package:hunianku/features/bookmark/controllers/bookmark_controller.dart'; 

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  // Gunakan Singleton Controller
  final BookmarkController _controller = BookmarkController();

  final Color containerColor = const Color(0xFFFBFBF9); 
  final Color cardColor = Colors.white; 
  final Color primaryGreen = const Color(0xFF4A6525);
  final Color buttonRed = const Color(0xFF6B1212);

  @override
  void initState() {
    super.initState();
    // Ambil data bookmark dari server saat halaman ini dibuka
    _controller.fetchBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Bookmark',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),

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
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ValueListenableBuilder<List<BookmarkModel>>(
                  valueListenable: _controller.bookmarks,
                  builder: (context, bookmarkList, child) {
                    if (bookmarkList.isEmpty) {
                      return const Center(child: Text("Belum ada kost yang ditandai.", style: TextStyle(color: Colors.grey)));
                    }

                    // Tampilkan List
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 32.0, left: 24.0, right: 24.0, bottom: 100.0, 
                      ),
                      itemCount: bookmarkList.length,
                      itemBuilder: (context, index) {
                        // Ambil kost dari dalam objek BookmarkModel
                        final kost = bookmarkList[index].kost;
                        if (kost == null) return const SizedBox(); 
                        return _buildBookmarkCard(context, kost);
                      },
                    );
                  }
                );
              }
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkCard(BuildContext context, KostModel kost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 130,
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
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEBE1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kost.jenis,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp. ${kost.harga}/bulan',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // --- TOMBOL HAPUS DARI BOOKMARK ---
                    IconButton(
                      onPressed: () {
                        _showDeleteBookmarkDialog(context, kost.idkost);
                      },
                      icon: Icon(Icons.delete, color: buttonRed, size: 24),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 8),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailKostPage(kost: kost),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        minimumSize: const Size(0, 28),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Lihat Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

  // --- FUNGSI POP-UP HAPUS BOOKMARK ---
  void _showDeleteBookmarkDialog(BuildContext context, String idkost) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.bookmark_remove_rounded, color: Colors.orange, size: 60),
              SizedBox(height: 16),
              Text(
                "Hapus Bookmark?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus kost ini dari daftar bookmark?",
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
                Navigator.pop(dialogContext);
                _controller.removeBookmarkByKostId(context, idkost);
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