import 'package:flutter/material.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/services/kost_service.dart';
import 'package:hunianku/services/session_service.dart';

class KostKuController {
  final KostService _kostService = KostService();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<KostModel>> kostKuList = ValueNotifier<List<KostModel>>([]);

  // 1. Mengambil data Kost Ku
  Future<void> fetchKostKu() async {
    isLoading.value = true;
    try {
      // Ambil iduser dari session
      final iduser = await SessionService.getIdUser() ?? ''; 
      
      if (iduser.isNotEmpty) {
        final data = await _kostService.getKostByPemilik(iduser);
        kostKuList.value = data;
      }
    } catch (e) {
      debugPrint("Error mengambil Kost Ku: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Menyimpan Edit Kost
  Future<void> simpanEditKost(BuildContext context, KostModel kostUpdate, bool isDraft) async {
    isLoading.value = true;
    try {
      if (isDraft) {
        // Jika asalnya dari Draf, simpan ke Hive
        await _kostService.updateDraftLokal(kostUpdate);
      } else {
        // Jika asalnya dari Kost Ku, simpan ke MongoDB
        await _kostService.updateKostRemote(kostUpdate);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isDraft ? 'Draf berhasil diperbarui!' : 'Kost berhasil diperbarui!'),
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> hapusKost(BuildContext context, String idkost) async {
    isLoading.value = true;
    try {
      await _kostService.hapusKostRemote(idkost);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kost berhasil dihapus selamanya.'), backgroundColor: Colors.green),
        );
        // Otomatis tarik data terbaru agar yang baru dihapus hilang dari layar
        fetchKostKu(); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus kost: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}