import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/review/model/review_model.dart';
import 'package:hunianku/features/review/controllers/review_controller.dart'; 
import 'package:hunianku/services/session_service.dart'; 
import 'package:hunianku/features/review/views/tambah_review_page.dart';

class ReviewKostPage extends StatefulWidget {
  final KostModel kost;
  const ReviewKostPage({super.key, required this.kost});

  @override
  State<ReviewKostPage> createState() => _ReviewKostPageState();
}

class _ReviewKostPageState extends State<ReviewKostPage> {
  final ReviewController _controller = ReviewController();
  String _userRole = '';

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color containerColor = const Color(0xFFFBFBF9); 
  final Color cardColor = Colors.white; 
  // Warna hijau olive tua agar kontras dengan ikon putih
  final Color primaryGreen = const Color(0xFF4A6525); 

  @override
  void initState() {
    super.initState();
    _controller.fetchReviews(widget.kost.idkost);
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await SessionService.getRole() ?? '';
    setState(() {
      _userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Container(
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
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Review',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- LIST ULASAN ---
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _controller.isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ValueListenableBuilder<List<ReviewModel>>(
                      valueListenable: _controller.reviewsList,
                      builder: (context, reviews, child) {
                        if (reviews.isEmpty) {
                          return const Center(child: Text("Belum ada ulasan untuk kost ini."));
                        }

                        return ListView.builder(
                          // Jarak bawah 100 agar kartu terakhir aman dari tombol FAB
                          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0, bottom: 100.0),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            return _buildReviewCard(reviews[index]);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // --- PERBAIKAN: FLOATING ACTION BUTTON YANG LEBIH INTERAKTIF ---
      floatingActionButton: _userRole == 'penghuni' 
          ? FloatingActionButton(
              onPressed: () {
                // --- MEMUNCULKAN POPUP KONFIRMASI ---
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      title: const Text(
                        'Konfirmasi Penghuni',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        'Apakah Anda benar merupakan penghuni dari kost ini?',
                        style: TextStyle(height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), // Tutup dialog jika batal
                          child: const Text('Bukan', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog konfirmasi terlebih dahulu
                            
                            // Lanjut navigasi ke halaman form
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TambahReviewPage(kost: widget.kost),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Ya, Saya Penghuni', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  },
                );
              },
              backgroundColor: primaryGreen,
              elevation: 5,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.rate_review_outlined, 
                color: Colors.white, 
                size: 25,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // WIDGET CARD REVIEW
  Widget _buildReviewCard(ReviewModel review) {
    int starCount = int.tryParse(review.rating) ?? 5;

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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                review.user?.nama ?? 'Pengguna Anonim', 
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            children: List.generate(
              starCount, 
              (index) => const Icon(Icons.star, color: Color(0xFFEBC144), size: 18),
            ),
          ),
          
          const SizedBox(height: 12),
          Text(
            review.komentar,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            review.tanggal,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}