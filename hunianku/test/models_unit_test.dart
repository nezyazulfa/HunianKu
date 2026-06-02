import 'package:flutter_test/flutter_test.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/note/model/note_model.dart';
import 'package:hunianku/features/review/model/review_model.dart';
import 'package:hunianku/features/bookmark/model/bookmark_model.dart';

void main() {
  group('Pure Unit Test: Models Data Parsing', () {
    
    // -- UserModel --
    test('TC-MOD-01 & TC-MDL-01: UserModel.fromMap parses MongoDB JSON correctly', () {
      final map = {'_id': ObjectId(), 'iduser': 'USR-1', 'password': '123', 'email': 'siti@mail.com', 'nama': 'Siti', 'role': 'penghuni'};
      final user = UserModel.fromMap(map);
      expect(user.iduser, 'USR-1');
      expect(user.nama, 'Siti');
    });

    test('TC-MDL-02: UserModel.toMap converts object to valid MongoDB Map', () {
      final user = UserModel(iduser: 'USR-1', password: '123', email: 'siti@mail.com', nama: 'Siti', role: 'penghuni');
      final map = user.toMap();
      expect(map.containsKey('_id'), isTrue);
      expect(map['iduser'], 'USR-1');
    });

    // -- KostModel --
    test('TC-MOD-02 & TC-MDL-04: KostModel.toMap nests User object correctly', () {
      final user = UserModel(iduser: 'U-1', password: '1', email: 'e', nama: 'Owner', role: 'pemilik');
      final kost = KostModel(idkost: 'K-1', user: user, namakost: 'Kost', jenis: '', alamat: '', lokasi: '', harga: '', kontak: '', daftarfasilitas: '', deskripsi: '', status: '');
      final map = kost.toMap();
      expect(map['user'], isNotNull);
      expect(map['user']['nama'], 'Owner');
    });

    test('TC-MDL-03: KostModel.fromMap handles empty lists securely', () {
      final map = {'_id': ObjectId(), 'idkost': 'K-1', 'namakost': 'Kost Indah'}; // daftarFoto tidak ada
      final kost = KostModel.fromMap(map);
      expect(kost.namakost, 'Kost Indah');
      expect(kost.daftarFoto, isEmpty); 
    });

    // -- NoteModel --
    test('TC-MOD-03 & TC-MDL-05: NoteModel Safely handles nested relations (Null-safety)', () {
      final map = {'_id': ObjectId(), 'idnote': 'N-1', 'catatan': 'Bocor', 'tanggal': '2026'}; // objek kost hilang
      final note = NoteModel.fromMap(map);
      expect(note.idnote, 'N-1');
      expect(note.kost, isNull); 
    });

    // -- ReviewModel --
    test('TC-MOD-04 & TC-MDL-06: ReviewModel Applies default rating "5" if missing', () {
      final map = {'_id': ObjectId(), 'idreview': 'R-1', 'komentar': 'Mantap', 'tanggal': '2026'}; // rating hilang
      final review = ReviewModel.fromMap(map);
      expect(review.rating, '5'); 
    });

    test('TC-MDL-07: ReviewModel.toMap structure is correct', () {
      final review = ReviewModel(idreview: 'R-1', rating: '4', komentar: 'Ok', tanggal: '2026');
      final map = review.toMap();
      expect(map['rating'], '4');
    });

    // -- BookmarkModel --
    test('TC-MDL-08: BookmarkModel Parses correctly from Map', () {
      final map = {'_id': ObjectId(), 'idbookmark': 'B-1', 'tanggal': '2026'};
      final bookmark = BookmarkModel.fromMap(map);
      expect(bookmark.idbookmark, 'B-1');
    });

    test('TC-MOD-05: BookmarkModel Should be wrapped successfully (toMap)', () {
      final bookmark = BookmarkModel(idbookmark: 'B-1', tanggal: '2026');
      final map = bookmark.toMap();
      expect(map['idbookmark'], 'B-1');
    });
  });
}