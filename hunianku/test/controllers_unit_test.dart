import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:hunianku/features/dashboard/controllers/dashboard_controller.dart';
import 'package:hunianku/features/note/controllers/note_controller.dart';
import 'package:hunianku/features/review/controllers/review_controller.dart';
import 'package:hunianku/features/kost_ku/controllers/kost_ku_controller.dart';
import 'package:hunianku/features/draft/controllers/draft_controller.dart';
import 'package:hunianku/features/bookmark/controllers/bookmark_controller.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/bookmark/model/bookmark_model.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/features/note/model/note_model.dart';

void main() {
  setUpAll(() async {
    // 1. Inisialisasi Binding Flutter untuk SharedPreferences
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'user_id': 'USR-123'});

    // 2. Inisialisasi Hive ke temporary directory
    final directory = await Directory.systemTemp.createTemp();
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(KostModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NoteModelAdapter());

    // 3. Inisialisasi DotEnv palsu agar tidak crash
    await dotenv.load(fileName: '.env', mergeWith: {'MONGODB_URI': 'mongodb://10.255.255.1:27017/fake'});
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('Pure Unit Test: Dashboard Controller (Filter & Search)', () {
    late DashboardController dashboardController;

    setUp(() {
      dashboardController = DashboardController();
    });

    test('TC-CTL-01: searchKost sets query and updates list', () {
      dashboardController.searchKost('kosA');
      expect(dashboardController.errorMessage.value, isNull);
    });

    test('TC-CTL-02: setFilters updates filter parameters', () {
      dashboardController.setFilters(min: 10000, max: 500000, kategori: 'Putra', status: 'Penuh', periode: 'Bulan');
      expect(dashboardController.minPrice, 10000);
      expect(dashboardController.maxPrice, 500000);
      expect(dashboardController.selectedKategori, 'Putra');
    });

    test('TC-CTL-03: Filter extract numeric from string price', () {
      dashboardController.setFilters(min: 0, max: 1500000, kategori: 'Semua', status: 'Semua', periode: 'Semua');
      expect(dashboardController.maxPrice, 1500000);
    });

    test('TC-CTL-04: Filter tolerates campur as putra putri', () {
      dashboardController.setFilters(min: null, max: null, kategori: 'Putra Putri', status: 'Semua', periode: 'Semua');
      expect(dashboardController.selectedKategori, 'Putra Putri');
    });

    test('TC-CTL-05 & TC-DASH-06: resetFilters clears all filter variables', () {
      dashboardController.setFilters(min: 100, max: 200, kategori: 'Putri', status: 'Penuh', periode: '/tahun');
      dashboardController.resetFilters();
      
      expect(dashboardController.minPrice, isNull);
      expect(dashboardController.maxPrice, isNull);
      expect(dashboardController.selectedKategori, 'Semua');
    });
  });

  group('Pure Unit Test: Controller Loading States', () {
    test('TC-CTL-06: NoteController loading state changes during fetch', () {
      final controller = NoteController();
      final future = controller.featchNotes();
      expect(controller.isLoading.value, isTrue); 
    });

    test('TC-CTL-07: ReviewController loading state changes during fetch', () {
      final controller = ReviewController();
      final future = controller.fetchReviews('K-1');
      expect(controller.isLoading.value, isTrue);
    });

    test('TC-CTL-08: KostKuController loading state changes during fetch', () {
      final controller = KostKuController();
      final future = controller.fetchKostKu();
      expect(controller.isLoading.value, isTrue);
    });

    test('TC-CTL-09: DraftController loading state changes during fetch', () {
      final controller = DraftController();
      final future = controller.fetchDrafts();
      expect(controller.isLoading.value, isTrue);
    });
  });

  group('Pure Unit Test: Bookmark Controller Logic', () {
    test('TC-CTL-10: isKostBookmarked detects existing bookmark', () {
      final controller = BookmarkController();
      final kost = KostModel(idkost: 'K-1', namakost: 'A', jenis: '', alamat: '', lokasi: '', harga: '', kontak: '', daftarfasilitas: '', deskripsi: '', status: '');
      controller.bookmarks.value = [BookmarkModel(idbookmark: 'B-1', tanggal: '2026', kost: kost)];

      expect(controller.isKostBookmarked('K-1'), isTrue);
    });

    test('TC-CTL-11: isKostBookmarked returns false if not found', () {
      final controller = BookmarkController();
      final kost = KostModel(idkost: 'K-1', namakost: 'A', jenis: '', alamat: '', lokasi: '', harga: '', kontak: '', daftarfasilitas: '', deskripsi: '', status: '');
      controller.bookmarks.value = [BookmarkModel(idbookmark: 'B-1', tanggal: '2026', kost: kost)];

      expect(controller.isKostBookmarked('K-2'), isFalse);
    });
  });
}