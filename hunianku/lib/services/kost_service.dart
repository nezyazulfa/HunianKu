import 'package:hunianku/services/mongo_service.dart';
import 'package:hive/hive.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart'; 

class KostService {
  final MongoService _mongo = MongoService();
  final String _collectionName = 'kost'; // Pastikan nama tabel di MongoDB adalah 'kost'

  // Fungsi untuk mengambil semua data kost
  Future<List<KostModel>> getAllKost() async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      // Ambil semua data dalam bentuk list of map
      final data = await collection.find().toList();
      
      // Ubah data JSON dari MongoDB menjadi bentuk KostModel
      return data.map((json) => KostModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kost: $e');
    }
  }

  // 1. SIMPAN KE MONGODB (Online)
  Future<void> simpanKostRemote(KostModel kostBaru) async {
    try {
      await _mongo.insertDocument(_collectionName, kostBaru.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan ke server: $e');
    }
  }

  // 2. SIMPAN KE HIVE (Lokal / Draf)
  Future<void> simpanKostLokal(KostModel kostBaru) async {
    try {
      var box = await Hive.openBox<KostModel>('draft_box');
      await box.put(kostBaru.idkost, kostBaru);
    } catch (e) {
      throw Exception('Gagal menyimpan draf lokal: $e');
    }
  }

  // 3. SIMPAN KE PENDING SYNC (Gagal karena tidak ada internet)
  Future<void> simpanPendingLokal(KostModel kostBaru) async {
    try {
      // Gunakan kotak khusus "pending_box"
      var box = await Hive.openBox<KostModel>('pending_box');
      await box.put(kostBaru.idkost, kostBaru);
    } catch (e) {
      throw Exception('Gagal menyimpan antrean: $e');
    }
  }
}