import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/review/controllers/review_controller.dart';

class TambahReviewPage extends StatefulWidget {
  final KostModel kost;

  const TambahReviewPage({super.key, required this.kost});

  @override
  State<TambahReviewPage> createState() => _TambahReviewPageState();
}

class _TambahReviewPageState extends State<TambahReviewPage> {
  final ReviewController _controller = ReviewController();
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5; 
  
  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color containerColor = const Color(0xFFFBFBF9); 
  final Color cardColor = Colors.white; 
  final Color primaryGreen = const Color(0xFF4A6525); 
  final Color starColor = const Color(0xFFEBC144);

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
                  const Text(
                    'Tambah Ulasan',
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
                            // Judul Kost
                            Text(
                              widget.kost.namakost,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),

                            // Pilihan Bintang (Rating)
                            const Text('Berikan Penilaian:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
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
                            
                            // Form Input Ulasan
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
                            // Matikan tombol jika sedang loading
                            onPressed: isLoading ? null : () {
                              _controller.tambahReview(
                                context, 
                                widget.kost, 
                                _selectedRating, 
                                _reviewController.text.trim()
                              );
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
                                : const Text('Kirim Ulasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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