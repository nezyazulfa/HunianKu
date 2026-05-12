import 'package:flutter/material.dart';
import 'package:hunianku/features/note/model/note_model.dart';
import 'package:hunianku/services/note_service.dart';
import 'package:hunianku/services/session_service.dart';

class NoteController {
  final NoteService _noteService = NoteService();
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<NoteModel>> noteList = ValueNotifier<List<NoteModel>>([]);

  // Fungsi Tarik Data
  Future<void> featchNotes() async {
    isLoading.value = true;
    try{
      // Ambil iduser dari session lokal
      final String? userId = await SessionService.getUserId(); 
      if (userId != null) {
        final data = await _noteService.getnotebyuser(userId);
        noteList.value = data;
      }
    }catch(e){
      print('Gagal memuat catatan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Simpan Editan
  Future<bool> simpanEditNote(NoteModel updatedNote) async {
    isLoading.value = true;
    bool isSuccess = false;
    try {
      await _noteService.updateNote(updatedNote);
      await featchNotes(); 
      isSuccess = true;
    } catch (e) {
      print('Gagal edit catatan: $e');
      isSuccess = false; 
    } finally {
      isLoading.value = false;
    }
    return isSuccess;
  }
  // Fungsi Hapus Note
  Future<bool> hapusNote(String noteId) async {
    isLoading.value = true;
    bool isSuccess = false;

    try {
      await _noteService.deleteNote(noteId);
      await featchNotes(); // Tarik ulang data agar catatan yang dihapus hilang dari layar
      isSuccess = true;
    } catch (e) {
      print('Gagal menghapus catatan: $e');
      isSuccess = false;
    } finally {
      isLoading.value = false;
    }

    return isSuccess;
  }
}
