import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/services/kost_service.dart';

class TambahKostController {
  final KostService _kostService = KostService();
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  // LOGIKA TOMBOL "SIMPAN"
  Future<void> simpanKost(BuildContext context, KostModel kost, VoidCallback onSuccess) async {
    isLoading.value = true;
    try {
      // Mencoba koneksi dan menyimpan ke MongoDB Atlas
      await _kostService.simpanKostRemote(kost);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil! Data tersimpan di server.'), backgroundColor: Colors.green),
        );
        onSuccess();
      }
    } catch (e) {
      // JIKA GAGAL (Koneksi Timeout / Tidak ada internet)
      await _kostService.simpanPendingLokal(kost);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koneksi terputus. Data disimpan otomatis di Draf Lokal.'), 
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        onSuccess();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // LOGIKA TOMBOL "DRAF"
  Future<void> simpanKeDraf(BuildContext context, KostModel kost, VoidCallback onSuccess) async {
    isLoading.value = true;
    try {
      await _kostService.simpanKostLokal(kost);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil! Data disimpan sebagai Draf.'), backgroundColor: Colors.blue),
        );
        onSuccess();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan draf: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}