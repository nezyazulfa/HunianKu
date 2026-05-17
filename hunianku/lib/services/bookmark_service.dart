import 'package:hunianku/services/mongo_service.dart';
import 'package:hunianku/features/bookmark/model/bookmark_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class BookmarkService {
  final MongoService _mongo = MongoService();
  final String _collectionName = 'bookmark'; 

  // Mengambil daftar bookmark berdasarkan ID User (Penghuni)
  Future<List<BookmarkModel>> getBookmarksByUser(String iduser) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      // Kita cari bookmark yang iduser-nya cocok dengan yang sedang login
      final data = await collection.find(where.eq('user.iduser', iduser)).toList();
      
      return data.map((json) => BookmarkModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data bookmark: $e');
    }
  }

  // Menyimpan bookmark baru ke database
  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      await collection.insertOne(bookmark.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan bookmark: $e');
    }
  }

  // Menghapus bookmark berdasarkan ID Kost dan ID User
  Future<void> removeBookmark(String idkost, String iduser) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      await collection.deleteOne(
        where.eq('kost.idkost', idkost).eq('user.iduser', iduser)
      );
    } catch (e) {
      throw Exception('Gagal menghapus bookmark: $e');
    }
  }
}