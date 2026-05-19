import 'package:hunianku/services/mongo_service.dart';
import 'package:hunianku/features/review/model/review_model.dart';
import 'package:mongo_dart/mongo_dart.dart'; 

class ReviewService {
  final MongoService _mongo = MongoService();
  final String _collectionName = 'review'; 

  // Mengambil ulasan khusus untuk satu kost
  Future<List<ReviewModel>> getReviewsByKost(String idkost) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      
      // Mencari berdasarkan idkost yang bersarang di dalam objek kost
      final data = await collection.find(where.eq('kost.idkost', idkost)).toList();
      
      return data.map((json) => ReviewModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data review: $e');
    }
  }

  // Menyimpan ulasan baru ke MongoDB
  Future<void> addReviewRemote(ReviewModel newReview) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      await collection.insertOne(newReview.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan ulasan ke server: $e');
    }
  }

  // Memperbarui ulasan yang sudah ada di MongoDB
  Future<void> updateReviewRemote(String idMongo, String ratingBaru, String komentarBaru) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      
      // Update data berdasarkan ObjectId dari MongoDB
      await collection.updateOne(
        where.id(ObjectId.fromHexString(idMongo)), 
        modify
          .set('rating', ratingBaru)
          .set('komentar', komentarBaru)
          .set('tanggal', '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}')
      );
    } catch (e) {
      throw Exception('Gagal memperbarui ulasan: $e');
    }
  }

  // Menghapus ulasan dari MongoDB
  Future<void> deleteReviewRemote(String idMongo) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      // Menghapus data berdasarkan ObjectId dari MongoDB
      await collection.deleteOne(where.id(ObjectId.fromHexString(idMongo)));
    } catch (e) {
      throw Exception('Gagal menghapus ulasan: $e');
    }
  }
}