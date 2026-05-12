import 'package:shared_preferences/shared_preferences.dart';
import 'package:hunianku/features/auth/model/user_model.dart';

class SessionService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserNama = 'user_nama';
  static const String _keyUserRole = 'user_role'; 

  // Menyimpan data setelah login berhasil
  static Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.iduser); 
    await prefs.setString(_keyUserNama, user.nama);
    await prefs.setString(_keyUserRole, user.role); 
  }

  // Mengambil role user saat ini
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  // Mengambil nama user saat ini
  static Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserNama);
  }

  // PERBAIKAN: Mengambil ID user saat ini
  static Future<String?> getIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Menghapus data saat logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}