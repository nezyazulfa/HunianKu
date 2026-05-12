import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/review/model/review_model.dart';
import 'package:hunianku/features/review/controllers/review_controller.dart'; 

class ReviewKostPage extends StatefulWidget {
  // Menerima data kost yang sedang diklik
  final KostModel kost;

  const ReviewKostPage({super.key, required this.kost});

  @override
  State<ReviewKostPage> createState() => _ReviewKostPageState();
}

class _ReviewKostPageState extends State<ReviewKostPage> {
  // Panggil Controller yang baru saja dibuat
  final ReviewController _controller = ReviewController();

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color containerColor = const Color(0xFFFBFBF9); 
  final Color cardColor = Colors.white; 

  @override
  void initState() {
    super.initState();
    // Meminta Controller mengambil data saat halaman dibuka
    _controller.fetchReviews(widget.kost.idkost);
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

              // --- LIST ULASAN DARI MONGODB (Diubah memakai ValueListenableBuilder) ---
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
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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