import 'package:flutter/material.dart';
import 'package:hunianku/features/bookmark/model/bookmark_model.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/services/bookmark_service.dart';
import 'package:hunianku/services/session_service.dart';

class BookmarkController {
  // Singleton pattern agar state sinkron di semua halaman
  static final BookmarkController _instance = BookmarkController._internal();
  factory BookmarkController() => _instance;
  BookmarkController._internal();

  final BookmarkService _bookmarkService = BookmarkService();

  // State penyimpan daftar bookmark
  ValueNotifier<List<BookmarkModel>> bookmarks = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  // Mengambil data bookmark dari database berdasarkan user yang login
  Future<void> fetchBookmarks() async {
    isLoading.value = true;
    try {
      final iduser = await SessionService.getIdUser();
      if (iduser != null && iduser.isNotEmpty) {
        final data = await _bookmarkService.getBookmarksByUser(iduser);
        bookmarks.value = data;
      }
    } catch (e) {
      debugPrint("Error memuat bookmark: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Menambahkan Kost ke Bookmark
  Future<void> addBookmark(BuildContext context, KostModel kost) async {
    try {
      final iduser = await SessionService.getIdUser();
      final nama = await SessionService.getNama();
      final role = await SessionService.getRole();

      if (iduser == null) return;

      // Membuat objek User sementara dari Session
      final currentUser = UserModel(
        iduser: iduser, 
        nama: nama ?? '', 
        role: role ?? '', 
        email: '', 
        password: ''
      );

      final newBookmark = BookmarkModel(
        idbookmark: 'BMK-${DateTime.now().millisecondsSinceEpoch}',
        kost: kost,
        user: currentUser,
        tanggal: 'Ditambahkan pada ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      );

      // Simpan ke MongoDB
      await _bookmarkService.addBookmark(newBookmark);

      // Update UI secara lokal agar instan
      bookmarks.value = [...bookmarks.value, newBookmark];

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disimpan ke Bookmark!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error tambah bookmark: $e");
    }
  }

  // Menghapus Kost dari Bookmark
  Future<void> removeBookmarkByKostId(BuildContext context, String kostId) async {
    try {
      final iduser = await SessionService.getIdUser();
      if (iduser == null) return;

      // Hapus dari MongoDB
      await _bookmarkService.removeBookmark(kostId, iduser);

      // Hapus dari state lokal
      bookmarks.value = bookmarks.value.where((b) => b.kost?.idkost != kostId).toList();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari Bookmark!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Error hapus bookmark: $e");
    }
  }

  // Mengecek apakah kost sudah ada di bookmark
  bool isKostBookmarked(String kostId) {
    return bookmarks.value.any((b) => b.kost?.idkost == kostId);
  }
}