import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:hive/hive.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/services/kost_service.dart';

class SyncService {
  final KostService _kostService = KostService();

  void mulaiPantauInternet() {
    // onStatusChange akan terus memantau perubahan internet di background
    InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          print('🌐 Internet Terhubung! Mengecek antrean...');
          _syncPendingData();
          break;
        case InternetConnectionStatus.disconnected:
          print('🚫 Internet Terputus. Masuk mode offline.');
          break;
      }
    });
  }

  // Fungsi untuk mengirim data dari lokal (pending_box) ke MongoDB
  Future<void> _syncPendingData() async {
    try {
      var box = await Hive.openBox<KostModel>('pending_box');
      
      // Jika kosong, tidak perlu lakukan apa-apa
      if (box.isEmpty) {
        print('✅ Tidak ada data yang antre.');
        return;
      }

      print('🔄 Memulai Sinkronisasi ${box.length} data...');

      for (var key in box.keys.toList()) {
        var kostPending = box.get(key);
        
        if (kostPending != null) {
          try {
            await _kostService.simpanKostRemote(kostPending);
            await box.delete(key);
            print('✅ Sukses upload kost: ${kostPending.namakost}');
          } catch (e) {
            print('❌ Gagal upload kost ${kostPending.namakost}: $e');
          }
        }
      }
    } catch (e) {
      print('Error saat mencoba sinkronisasi: $e');
    }
  }
}