import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:hunianku/services/session_service.dart';
import 'package:hunianku/services/kost_service.dart';
import 'package:hunianku/services/note_service.dart';
import 'package:hunianku/services/mongo_service.dart';
import 'package:hunianku/services/auth_service.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/note/model/note_model.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    
    final directory = await Directory.systemTemp.createTemp();
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(KostModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NoteModelAdapter());

    // Ganti dari localhost ke IP yang tidak ada (Blackhole) agar PASTI terjadi Timeout
    await dotenv.load(fileName: '.env', mergeWith: {'MONGODB_URI': 'mongodb://10.255.255.1:27017/fake'});
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('Pure Unit Test: Session Service', () {
    test('TC-AUTH-01 & TC-SRV-01: saveSession stores data in SharedPreferences', () async {
      final user = UserModel(iduser: 'USR-123', nama: 'Siti', role: 'pemilik', email: 'siti@mail.com', password: '');
      await SessionService.saveSession(user);

      final id = await SessionService.getIdUser();
      expect(id, 'USR-123');
    });

    test('TC-SRV-02: clearSession wipes all SharedPreferences', () async {
      await SessionService.clearSession();
      final id = await SessionService.getIdUser();
      expect(id, isNull);
    });
  });

  group('Pure Unit Test: Local Storage Services (Hive)', () {
    final kostService = KostService();
    final dummyKost = KostModel(idkost: 'K-SRV1', namakost: 'Local', jenis: '', alamat: '', lokasi: '', harga: '', kontak: '', daftarfasilitas: '', deskripsi: '', status: '');

    test('TC-SRV-03: simpanKostLokal inserts to Hive draft_box', () async {
      await kostService.simpanKostLokal(dummyKost);
      final drafts = await kostService.getAllDrafts();
      expect(drafts.length, 1);
    });

    test('TC-SRV-04: hapusDraftLokal deletes from Hive draft_box', () async {
      await kostService.hapusDraftLokal('K-SRV1');
      final drafts = await kostService.getAllDrafts();
      expect(drafts.length, 0);
    });

    test('TC-SRV-05: simpanPendingLokal inserts to pending_box', () async {
      await kostService.simpanPendingLokal(dummyKost);
      var box = await Hive.openBox<KostModel>('pending_box');
      expect(box.containsKey('K-SRV1'), isTrue);
    });

    final noteService = NoteService();
    final dummyNote = NoteModel(idnote: 'N-SRV1', catatan: 'Test', tanggal: '2026');

    test('TC-SRV-06: simpanNotePendingLokal saves to Hive', () async {
      await noteService.simpanNotePendingLokal(dummyNote);
      var box = await Hive.openBox<NoteModel>('note_pending_box');
      expect(box.containsKey('N-SRV1'), isTrue);
    });

    test('TC-SRV-07: getPendingNotes retrieves all pending notes', () async {
      final pendingNotes = await noteService.getPendingNotes();
      expect(pendingNotes.isNotEmpty, isTrue);
    });
  });

  group('Pure Unit Test: Network Resilience & Error Handling', () {
    test('TC-SRV-08: MongoService.connect throws Exception on invalid URI', () async {
      final mongoService = MongoService();
      // Pastikan _db ditutup jika sebelumnya ada sisa koneksi
      await mongoService.close(); 
      expect(() async => await mongoService.connect(), throwsException);
    });

    test('TC-SRV-09: AuthService.login catches DB failure and returns false', () async {
      final authService = AuthService();
      final result = await authService.login(email: 'test@mail.com', password: '123');
      
      expect(result['success'], isFalse);
      expect(result['message'], isNotNull);
    });
  });
}