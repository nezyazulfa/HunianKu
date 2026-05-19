import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/review/controllers/review_controller.dart';
import 'package:hunianku/features/review/model/review_model.dart'; // Import Model Review

class TambahReviewPage extends StatefulWidget {
  final KostModel kost;
  
  // Parameter baru untuk mode Edit
  final bool isEdit;
  final ReviewModel? existingReview;

  const TambahReviewPage({
    super.key, 
    required this.kost,
    this.isEdit = false, 
    this.existingReview,
  });

  @override
  State<TambahReviewPage> createState() => _TambahReviewPageState();
}

class _TambahReviewPageState extends State<TambahReviewPage> {
  final ReviewController _controller = ReviewController();
  late TextEditingController _reviewController;
  int _selectedRating = 5; 
  
  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color containerColor = const Color(0xFFFBFBF9); 
  final Color cardColor = Colors.white; 
  final Color primaryGreen = const Color(0xFF4A6525); 
  final Color starColor = const Color(0xFFEBC144);

  @override
  void initState() {
    super.initState();
    // Mengisi data jika masuk sebagai mode edit
    _reviewController = TextEditingController(
      text: widget.isEdit ? widget.existingReview?.komentar : ''
    );
    
    if (widget.isEdit && widget.existingReview != null) {
      _selectedRating = int.tryParse(widget.existingReview!.rating) ?? 5;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- HEADER ---
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
                  Text(
                    widget.isEdit ? 'Edit Ulasan' : 'Tambah Ulasan',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  // --- TOMBOL HAPUS (HANYA MUNCUL DI MODE EDIT) ---
                  if (widget.isEdit)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _controller.isLoading,
                        builder: (context, isLoading, child) {
                          return IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFF6B1212), size: 28), // Menggunakan warna merah buttonRed
                            onPressed: isLoading ? null : () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    title: const Text('Hapus Ulasan', style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: const Text('Apakah Anda yakin ingin menghapus ulasan ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _controller.deleteReview(context, widget.existingReview!.id); 
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF6B1212), // Merah
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        }
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- KONTEN UTAMA ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.kost.namakost,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            const Text('Berikan Penilaian:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            
                            // Bintang interaktif
                            Row(
                              children: List.generate(5, (index) {
                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    index < _selectedRating ? Icons.star : Icons.star_border,
                                    color: starColor,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedRating = index + 1;
                                    });
                                  },
                                );
                              }),
                            ),
                            const SizedBox(height: 24),
                            
                            // Form Input
                            Expanded(
                              child: TextField(
                                controller: _reviewController,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  hintText: 'Tuliskan pengalamanmu ngekost di sini...',
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- TOMBOL KIRIM ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0, top: 8.0), 
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _controller.isLoading,
                        builder: (context, isLoading, child) {
                          return ElevatedButton(
                            onPressed: isLoading ? null : () async {
                              if (widget.isEdit) {
                                await _controller.editReview(
                                  context, 
                                  widget.existingReview!.id,
                                  _selectedRating, 
                                  _reviewController.text.trim()
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ulasan berhasil diperbarui!'))
                                  );
                                  Navigator.pop(context, true); 
                                }
                              } else {
                                await _controller.tambahReview(
                                  context, 
                                  widget.kost, 
                                  _selectedRating, 
                                  _reviewController.text.trim()
                                );
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    widget.isEdit ? 'Simpan Perubahan' : 'Kirim Ulasan', 
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                  ),
                          );
                        }
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