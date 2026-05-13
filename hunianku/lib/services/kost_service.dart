import 'package:hunianku/services/mongo_service.dart';
import 'package:hive/hive.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:mongo_dart/mongo_dart.dart'; 

class KostService {
  final MongoService _mongo = MongoService();
  final String _collectionName = 'kost';

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

  // 4. Mengambil semua data draf dari Hive
  Future<List<KostModel>> getAllDrafts() async {
    try {
      var box = await Hive.openBox<KostModel>('draft_box');
      // Mengambil semua nilai (values) yang ada di dalam box dan mengubahnya jadi List
      return box.values.toList();
    } catch (e) {
      throw Exception('Gagal mengambil draf lokal: $e');
    }
  }

  // 5. Menghapus draf dari Hive berdasarkan ID
  Future<void> hapusDraftLokal(String idkost) async {
    try {
      var box = await Hive.openBox<KostModel>('draft_box');
      await box.delete(idkost); // Hapus berdasarkan idkost sebagai key
    } catch (e) {
      throw Exception('Gagal menghapus draf: $e');
    }
  }

  Future<void> updateDraftLokal(KostModel draftUpdate) async {
    try {
      var box = await Hive.openBox<KostModel>('draft_box');
      // Menggunakan idkost sebagai key untuk menimpa data lama
      await box.put(draftUpdate.idkost, draftUpdate);
    } catch (e) {
      throw Exception('Gagal memperbarui draf lokal: $e');
    }
  }

  // Mengambil kost khusus milik user (pemilik) yang sedang login
  Future<List<KostModel>> getKostByPemilik(String iduserPemilik) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      // Cari data kost yang atribut 'iduser'-nya sama dengan iduser pemilik yang login
      final data = await collection.find(where.eq('iduser', iduserPemilik)).toList();
      
      return data.map((json) => KostModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data Kost Ku: $e');
    }
  }

  // Menyimpan perubahan data kost (Edit) ke MongoDB
  Future<void> updateKostRemote(KostModel kostUpdate) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      
      // Update dokumen yang idkost-nya cocok dengan data yang baru
      await collection.updateOne(
        where.eq('idkost', kostUpdate.idkost),
        modify
          .set('namakost', kostUpdate.namakost)
          .set('deskripsi', kostUpdate.deskripsi)
          .set('alamat', kostUpdate.alamat)
          .set('lokasi', kostUpdate.lokasi)
          .set('daftarfasilitas', kostUpdate.daftarfasilitas)
          .set('harga', kostUpdate.harga)
          .set('kontak', kostUpdate.kontak)
          .set('jenis', kostUpdate.jenis)
          .set('status', kostUpdate.status)
      );
    } catch (e) {
      throw Exception('Gagal mengupdate kost: $e');
    }
  }

  Future<void> hapusKostRemote(String idkost) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      // Hapus dokumen yang idkost-nya cocok
      await collection.remove(where.eq('idkost', idkost));
    } catch (e) {
      throw Exception('Gagal menghapus kost dari server: $e');
    }
  }
}