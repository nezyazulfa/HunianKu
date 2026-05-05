import 'package:flutter/material.dart';
import 'package:hunianku/services/kost_service.dart';
// Sesuaikan path import model ini
import 'package:hunianku/features/dashboard/model/kost_model.dart'; 

class DashboardController {
  final KostService _kostService = KostService();

  // State reaktif untuk UI
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<KostModel>> kostList = ValueNotifier<List<KostModel>>([]);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Fungsi yang akan dipanggil saat halaman pertama kali dibuka
  Future<void> fetchKosts() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _kostService.getAllKost();
      kostList.value = data;
    } catch (e) {
      errorMessage.value = "Gagal memuat data: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }
}