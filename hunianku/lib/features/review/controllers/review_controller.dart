import 'package:flutter/material.dart';
import 'package:hunianku/features/review/model/review_model.dart';
import 'package:hunianku/services/review_service.dart';

class ReviewController {
  final ReviewService _reviewService = ReviewService();

  // State reaktif untuk UI menggunakan ValueNotifier
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<ReviewModel>> reviewsList = ValueNotifier<List<ReviewModel>>([]);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Fungsi untuk mengambil ulasan dari database berdasarkan ID Kost
  Future<void> fetchReviews(String idkost) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _reviewService.getReviewsByKost(idkost);
      reviewsList.value = data;
    } catch (e) {
      errorMessage.value = "Gagal memuat ulasan: ${e.toString()}";
      debugPrint("Error mengambil ulasan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}