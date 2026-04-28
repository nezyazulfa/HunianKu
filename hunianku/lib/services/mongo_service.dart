import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hunianku/helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
 final String _source = "mongo_service.dart";

  factory MongoService() {
    return _instance;
  }
  MongoService._internal();
 //inisiasi koneksi ke mongodb atlas
  Future<void> connect() async {
    await LogHelper.writeLog(
      "Mencoba koneksi MongoDB Atlas",
      source: "mongo_service.dart",
    );
    try{
    if (_db != null && _db!.isConnected) {
      return;
    }
    final uri = dotenv.env['MONGODB_URI'];
    if (uri == null) {
      throw Exception("MONGODB_URI tidak ditemukan di file .env");
    }

    _db = await Db.create(uri);
    await _db!.open().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception("Koneksi MongoDB timeout");
      },
    );
    if (!_db!.isConnected) {
      throw Exception(
        "Koneksi Timeout. Cek IP Whitelist (0.0.0.0/0) atau Sinyal HP.",
      );
}    //_collection = _db!.collection('user');
      await LogHelper.writeLog(
        "DATABASE: Terhubung & Koleksi Siap",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE: Gagal Koneksi - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  // Mendapatkan koleksi berdasarkan nama
  Future<DbCollection> getCollection(String collectionName) async {
    if (_db == null || !_db!.isConnected) {
      await connect();
    }
    return _db!.collection(collectionName);
  }

  // Mendapatkan nama database saat ini
  String? getDatabaseName() {
  return _db?.databaseName;
  }

  // menutup koneksi ke database
  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      await LogHelper.writeLog(
        "DATABASE: Koneksi ditutup",
        source: _source,
        level: 2,
      );
    }
  }

  // CREATE
  Future<void> insertDocument(String collectionName, Map<String, dynamic> data) async {
    try {
      final collection = await getCollection(collectionName);
      await collection.insertOne(data);
      await LogHelper.writeLog("SUCCESS: Insert ke '$collectionName'", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Insert Failed - $e", source: _source, level: 1);
      rethrow;
    }
  }

  // READ (Ambil semua data)
  Future<List<Map<String, dynamic>>> getAllDocuments(String collectionName) async {
    try {
      final collection = await getCollection(collectionName);
      return await collection.find().toList();
    } catch (e) {
      await LogHelper.writeLog("ERROR: Fetch Failed - $e", source: _source, level: 1);
      return [];
    }
  }

  // UPDATE
  Future<void> updateDocument(String collectionName, ObjectId id, Map<String, dynamic> updateData) async {
    try {
      final collection = await getCollection(collectionName);
      await collection.updateOne(where.id(id), {'\$set': updateData});
      await LogHelper.writeLog("SUCCESS: Update ID $id di '$collectionName'", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Update Failed - $e", source: _source, level: 1);
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteDocument(String collectionName, ObjectId id) async {
    try {
      final collection = await getCollection(collectionName);
      await collection.remove(where.id(id));
      await LogHelper.writeLog("SUCCESS: Hapus ID $id di '$collectionName'", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Delete Failed - $e", source: _source, level: 1);
      rethrow;
    }
  }
}