import 'package:hunianku/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:hunianku/features/note/model/note_model.dart';

class NoteService {
  final MongoService _mongo = MongoService();
  final String _collectionName = 'note';

  Future<List<NoteModel>> getnotebyuser(String iduser) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      final data = await collection
          .find(where.eq('user.iduser', iduser))
          .toList();
      return data.map((json) => NoteModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data catatan: $e');
    }
  }

  Future<void> updateNote(NoteModel updateNote) async {
    try {
      if (updateNote.id == null) throw Exception('ID note tidak ditemukan');
      final collection = await _mongo.getCollection(_collectionName);
      ObjectId objectId = ObjectId.fromHexString(updateNote.id!);
      await collection.updateOne(where.id(objectId), {'\$set': updateNote.toMap()});
    } catch (e) {
      throw Exception('Gagal update catatan: $e');
    }
  }

  // 3. Menghapus catatan berdasarkan Object ID
  Future<void> deleteNote(String noteId) async {
    try {
      final collection = await _mongo.getCollection(_collectionName);
      ObjectId objectId = ObjectId.fromHexString(noteId);
      await collection.deleteOne(where.id(objectId));
    } catch (e) {
      throw Exception('Gagal menghapus catatan: $e');
    }
  }
}
