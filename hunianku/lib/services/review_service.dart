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
}