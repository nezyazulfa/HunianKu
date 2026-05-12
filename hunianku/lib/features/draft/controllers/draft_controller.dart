import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/services/kost_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class DraftController {
  final KostService _kostService = KostService();

  // State Reaktif untuk UI
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<KostModel>> draftList = ValueNotifier<List<KostModel>>([]);

  // 1. Fungsi Mengambil Data Draf
  Future<void> fetchDrafts() async {
    isLoading.value = true;
    try {
      final data = await _kostService.getAllDrafts();
      draftList.value = data;
    } catch (e) {
      debugPrint("Error memuat draf: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Fungsi Menghapus Draf
  Future<void> hapusDraft(BuildContext context, String idkost) async {
    try {
      await _kostService.hapusDraftLokal(idkost);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Draf berhasil dihapus"), backgroundColor: Colors.green),
      );
      fetchDrafts(); // Refresh UI setelah dihapus
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus draf: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // 3. Fungsi Memposting Draf ke Database
  Future<void> postingDraft(BuildContext context, KostModel kost) async {
    isLoading.value = true;
    try {
      // Cek koneksi internet
      bool hasInternet = await InternetConnectionChecker().hasConnection;

      if (hasInternet) {
        // Jika ONLINE: Langsung simpan ke MongoDB
        await _kostService.simpanKostRemote(kost);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kost berhasil diposting!'), backgroundColor: Colors.green),
          );
        }
      } else {
        // Jika OFFLINE: Masukkan ke antrean sinkronisasi (Pending Sync)
        await _kostService.simpanPendingLokal(kost);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offline. Kost masuk antrean untuk diposting nanti.'), backgroundColor: Colors.orange),
          );
        }
      }

      // Setelah berhasil diposting atau diantrekan, hapus dari Draf
      await _kostService.hapusDraftLokal(kost.idkost);
      fetchDrafts(); // Refresh UI
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memposting kost: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}