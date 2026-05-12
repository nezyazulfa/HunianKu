import 'package:flutter/material.dart';
import 'package:hunianku/features/bookmark/model/bookmark_model.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';

class BookmarkController {
  // Singleton pattern agar state sinkron di semua halaman
  static final BookmarkController _instance = BookmarkController._internal();
  factory BookmarkController() => _instance;
  BookmarkController._internal();

  // State penyimpan daftar bookmark
  ValueNotifier<List<BookmarkModel>> bookmarks = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  // Mengambil data bookmark dari database (Simulasi)
  Future<void> fetchBookmarks() async {
    isLoading.value = true;
    // TODO: Ganti delay ini dengan fungsi HTTP GET ke MongoDB kamu
    await Future.delayed(const Duration(milliseconds: 500)); 
    // bookmarks.value = hasil fetch dari database;
    isLoading.value = false;
  }

  // Menambahkan Kost ke Bookmark
  Future<void> addBookmark(KostModel kost) async {
    // Membuat objek bookmark baru
    final newBookmark = BookmarkModel(
      idbookmark: 'BMK-${DateTime.now().millisecondsSinceEpoch}',
      kost: kost,
      tanggal: 'Ditambahkan pada ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );

    // Update UI secara lokal (agar instan)
    bookmarks.value = [...bookmarks.value, newBookmark];

    // TODO: Tambahkan fungsi HTTP POST untuk menyimpan 'newBookmark' ke MongoDB
  }

  // Menghapus Kost dari Bookmark
  Future<void> removeBookmarkByKostId(String kostId) async {
    // Hapus dari state lokal
    bookmarks.value = bookmarks.value.where((b) => b.kost?.id != kostId).toList();

    // TODO: Tambahkan fungsi HTTP DELETE ke MongoDB berdasarkan kostId / idbookmark
  }

  // Mengecek apakah kost sudah ada di bookmark
  bool isKostBookmarked(String kostId) {
    return bookmarks.value.any((b) => b.kost?.id == kostId);
  }
}