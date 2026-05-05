import 'package:hunianku/services/mongo_service.dart';
// Sesuaikan path import model ini dengan struktur foldermu
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
}