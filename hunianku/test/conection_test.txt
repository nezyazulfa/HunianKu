import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:hunianku/helpers/log_helper.dart';
import 'package:hunianku/services/mongo_service.dart';

void main(){
  const String sourceFile = "connection_test.dart";
  setUpAll(() async {await dotenv.load(fileName: ".env");});

  test(
    'Uji coba Full CRUD (Connect, Insert, Read, Update, Delete) di MongoService',
    () async {
      final mongoService = MongoService();
      const String testCollection = 'test_crud';
      await LogHelper.writeLog(
        "--- START CONNECTION TEST ---",
        source: sourceFile,
      );

      try {
        // TEST CONNECT
        await mongoService.connect();
        expect(dotenv.env['MONGODB_URI'], isNotNull);
        await LogHelper.writeLog(
          "SUCCESS: Koneksi Atlas Terverifikasi",
          source: sourceFile,
          level: 2, // INFO (Hijau)
        );
        // TEST CREATE
        final dummyId = ObjectId();
        final dummyData = {
          '_id': dummyId,
          'nama_kost': 'Kos Testing',
          'harga': 500000,
          'status': 'Tersedia'
        };
        await mongoService.insertDocument(testCollection, dummyData);
        await LogHelper.writeLog(
          "TEST 2: Insert Data Berhasil", 
          source: sourceFile, 
          level: 2
        );

        // TEST READ
        var result = await mongoService.getAllDocuments(testCollection);
        expect(result.any((doc) => doc['_id'] == dummyId), isTrue);
        await LogHelper.writeLog(
          "TEST 3: Read Data Berhasil (Data ditemukan)", 
          source: sourceFile, 
          level: 2
        );

        // TEST UPDATE
        final updateData = {
          'harga': 750000,
          'status': 'Penuh'
        };
        await mongoService.updateDocument(testCollection, dummyId, updateData);
        // Verifikasi update
        result = await mongoService.getAllDocuments(testCollection);
        final updatedDoc = result.firstWhere((doc) => doc['_id'] == dummyId);
        expect(updatedDoc['harga'], equals(750000));
        expect(updatedDoc['status'], equals('Penuh'));
        await LogHelper.writeLog(
          "TEST 4: Update Data Berhasil", 
          source: sourceFile, 
          level: 2
        );

        // TEST DELETE
        await mongoService.deleteDocument(testCollection, dummyId);
        // Panggil lagi untuk ngecek datanya udah hilang
        result = await mongoService.getAllDocuments(testCollection);
        expect(result.any((doc) => doc['_id'] == dummyId), isFalse);
        await LogHelper.writeLog(
          "TEST 5: Delete Data Berhasil (Data hilang)", 
          source: sourceFile, 
          level: 2
        );

      } catch (e) {
        await LogHelper.writeLog(
          "ERROR: Kegagalan test - $e",
          source: sourceFile,
          level: 1, // ERROR (Merah)
        );
        fail("test gagal: $e");
      } finally {
        await mongoService.close();
        await LogHelper.writeLog("--- END TEST ---", source: sourceFile);
      }
    },
  );
}