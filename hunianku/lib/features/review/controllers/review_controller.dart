import 'package:flutter/material.dart';
import 'package:hunianku/features/review/model/review_model.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/services/review_service.dart';
import 'package:hunianku/services/session_service.dart';

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

  // Fungsi untuk menambahkan ulasan baru
  Future<void> tambahReview(BuildContext context, KostModel kost, int rating, String komentar) async {
    isLoading.value = true;
    try {
      // 1. Ambil data user yang sedang login
      final iduser = await SessionService.getIdUser() ?? '';
      final nama = await SessionService.getNama() ?? 'Pengguna';
      final role = await SessionService.getRole() ?? 'penghuni';

      // 2. Buat identitas user sementara
      final currentUser = UserModel(
        iduser: iduser,
        nama: nama,
        role: role,
        email: '', password: '', 
      );

      // 3. Bungkus menjadi objek ReviewModel
      final newReview = ReviewModel(
        idreview: 'REV-${DateTime.now().millisecondsSinceEpoch}',
        kost: kost,
        user: currentUser,
        rating: rating.toString(),
        komentar: komentar,
        tanggal: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
      );

      // 4. Lempar ke Service untuk disimpan di MongoDB
      await _reviewService.addReviewRemote(newReview);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih! Ulasan berhasil dikirim.'), backgroundColor: Colors.green),
        );
        // Kembali ke halaman sebelumnya dan kirim sinyal 'true' tanda berhasil
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim ulasan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk mengedit ulasan yang sudah ada
  Future<void> editReview(BuildContext context, String? idMongoReview, int ratingBaru, String komentarBaru) async {
    if (idMongoReview == null) return;
    
    isLoading.value = true;
    try {
      await _reviewService.updateReviewRemote(idMongoReview, ratingBaru.toString(), komentarBaru);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui ulasan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk menghapus ulasan
  Future<void> deleteReview(BuildContext context, String? idMongoReview) async {
    if (idMongoReview == null) return;

    isLoading.value = true;
    try {
      await _reviewService.deleteReviewRemote(idMongoReview);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan berhasil dihapus!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus ulasan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}