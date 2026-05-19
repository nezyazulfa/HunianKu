import 'package:flutter/material.dart';
import 'package:hunianku/services/kost_service.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart'; 

class DashboardController {
  final KostService _kostService = KostService();

  // State reaktif untuk UI
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<KostModel>> kostList = ValueNotifier<List<KostModel>>([]);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  List<KostModel> _allKosts = [];

  // Variabel penyimpan status filter
  String _currentSearchQuery = '';
  int? minPrice;
  int? maxPrice;
  String selectedKategori = 'Semua';
  String selectedStatus = 'Semua';
  String selectedPeriode = 'Per Bulan';

  // Fungsi yang akan dipanggil saat halaman pertama kali dibuka
  Future<void> fetchKosts() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = await _kostService.getAllKost();
      _allKosts = data;
      _applyAllFilters();
    } catch (e) {
      errorMessage.value = "Gagal memuat data: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi saat user mengetik di Search Bar
  void searchKost(String query) {
    _currentSearchQuery = query;
    _applyAllFilters();
  }

  // Fungsi saat user menekan "Terapkan" di menu Filter
  void setFilters({
    int? min, 
    int? max, 
    required String kategori, 
    required String status,
    required String periode,
  }) {
    minPrice = min;
    maxPrice = max;
    selectedKategori = kategori;
    selectedStatus = status;
    selectedPeriode = periode;
    _applyAllFilters(); 
  }

  // Fungsi untuk mereset semua filter ke kondisi awal
  void resetFilters() {
    minPrice = null;
    maxPrice = null;
    selectedKategori = 'Semua';
    selectedStatus = 'Semua';
    selectedPeriode = 'Per Bulan';
    _applyAllFilters(); 
  }

  // LOGIKA UTAMA GABUNGAN SEARCH & FILTER
  void _applyAllFilters() {
    var filtered = _allKosts;

    // 1. Filter Pencarian Teks
    if (_currentSearchQuery.isNotEmpty) {
      final lowerCaseQuery = _currentSearchQuery.toLowerCase();
      filtered = filtered.where((kost) {
        return kost.namakost.toLowerCase().contains(lowerCaseQuery) ||
               kost.jenis.toLowerCase().contains(lowerCaseQuery) ||
               kost.alamat.toLowerCase().contains(lowerCaseQuery) ||
               kost.lokasi.toLowerCase().contains(lowerCaseQuery) ||
               kost.harga.toLowerCase().contains(lowerCaseQuery) ||
               kost.daftarfasilitas.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    // 2. Filter Kategori Kost
    if (selectedKategori != 'Semua') {
      filtered = filtered.where((kost) {
        String dbJenis = kost.jenis.toLowerCase();
        String filterJenis = selectedKategori.toLowerCase();
        // Cek toleransi: jika di DB namanya 'campur', kita anggap itu 'putra putri'
        if (dbJenis == 'campur' && filterJenis == 'putra putri') return true;
        return dbJenis == filterJenis;
      }).toList();
    }

    // 3. Filter Status
    if (selectedStatus != 'Semua') {
      filtered = filtered.where((kost) => kost.status.toLowerCase() == selectedStatus.toLowerCase()).toList();
    }

    // 4. Filter Rentang Harga (Mengekstrak angka asli dari string harga di database)
    if (minPrice != null || maxPrice != null) {
      filtered = filtered.where((kost) {
        // Membersihkan string (Misal: "Rp. 600.000/bulan" menjadi "600000")
        final numericString = kost.harga.replaceAll(RegExp(r'[^0-9]'), '');
        if (numericString.isEmpty) return true;
        
        final price = int.parse(numericString);
        bool passesMin = minPrice != null ? price >= minPrice! : true;
        bool passesMax = maxPrice != null ? price <= maxPrice! : true;
        
        return passesMin && passesMax;
      }).toList();
    }

    // Perbarui layar UI
    kostList.value = filtered;
  }
}