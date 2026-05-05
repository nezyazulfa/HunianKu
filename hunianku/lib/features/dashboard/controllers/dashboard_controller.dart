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

  List<KostModel> _allKosts = [];

  // Fungsi yang akan dipanggil saat halaman pertama kali dibuka
  Future<void> fetchKosts() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _kostService.getAllKost();
      _allKosts = data;
      kostList.value = data;
    } catch (e) {
      errorMessage.value = "Gagal memuat data: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk mencari Kost
  void searchKost(String query) {
    // Jika kotak pencarian kosong, kembalikan ke list asli
    if (query.isEmpty) {
      kostList.value = _allKosts;
      return;
    }

    // Ubah query menjadi huruf kecil agar pencarian tidak sensitif huruf besar/kecil
    final lowerCaseQuery = query.toLowerCase();

    // Filter data asli berdasarkan Nama, Jenis, Alamat, Lokasi, Harga, atau Fasilitas
    final filteredList = _allKosts.where((kost) {
      return kost.namakost.toLowerCase().contains(lowerCaseQuery) ||
             kost.jenis.toLowerCase().contains(lowerCaseQuery) ||
             kost.alamat.toLowerCase().contains(lowerCaseQuery) ||
             kost.lokasi.toLowerCase().contains(lowerCaseQuery) ||
             kost.harga.toLowerCase().contains(lowerCaseQuery) ||
             kost.daftarfasilitas.toLowerCase().contains(lowerCaseQuery);
    }).toList();

    // Perbarui UI dengan hasil pencarian
    kostList.value = filteredList;
  }
}