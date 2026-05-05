import 'package:flutter/material.dart';

class ReviewKostPage extends StatelessWidget {
  // 1. PERBAIKAN: Tambahkan tanda tanya (?) agar aman jika datanya kosong
  final Map<String, String>? kostData;

  // 2. PERBAIKAN: Hapus kata 'required' karena sekarang datanya boleh kosong
  const ReviewKostPage({super.key, this.kostData});

  final Color backgroundColor = const Color(0xFFEFEBE1); 
  final Color containerColor = const Color(0xFFFBFBF9); 
  final Color cardColor = Colors.white; 

  // 3. PERBAIKAN: Tambahkan 'const' di sini agar VS Code tidak error
  final List<Map<String, dynamic>> dummyReviews = const [
    {
      'username': '@nezyazulfa',
      'rating': 5,
      'review': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'date': '11.00 - 30 juni 2004',
    },
    {
      'username': '@nezyazulfa',
      'rating': 5,
      'review': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'date': '11.00 - 30 juni 2004',
    },
    {
      'username': '@nezyazulfa',
      'rating': 5,
      'review': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'date': '11.00 - 30 juni 2004',
    },
    {
      'username': '@nezyazulfa',
      'rating': 5,
      'review': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'date': '11.00 - 30 juni 2004',
    },
  ];

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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  itemCount: dummyReviews.length,
                  itemBuilder: (context, index) {
                    return _buildReviewCard(dummyReviews[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
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
              ),
              const SizedBox(width: 12),
              Text(
                review['username'] ?? 'User', // Aman dari null
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
              review['rating'] ?? 5, // Aman dari null
              (index) => const Icon(Icons.star, color: Color(0xFFEBC144), size: 18),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            review['review'] ?? '', // Aman dari null
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            review['date'] ?? '', // Aman dari null
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