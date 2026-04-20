import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hunianku/helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  DbCollection? _collection;
  final String _source = "mongo_service.dart";

  factory MongoService() {
    return _instance;
  }
  MongoService._internal();

  // Fungsi Internal untuk memastikan koleksi siap digunakan 
  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) {
      await LogHelper.writeLog(
        "INFO: Koleksi belum siap, mencoba rekoneksi...",
        source: _source,
        level: 3,
      );
      await connect();
    }
    return _collection!;
  }

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
    }

    _collection = _db!.collection('user');

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

  String? getDatabaseName() {
  return _db?.databaseName;
  }

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
}
