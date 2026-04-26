import 'package:hive/hive.dart';

part 'user_model.g.dart'; 

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String? id; 
  
  @HiveField(1)
  final String iduser; 
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String nama;
  
  @HiveField(4)
  final String role;

  UserModel({
    this.id,
    required this.iduser,
    required this.email,
    required this.nama,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] ?? map['id'], 
      iduser: map['iduser'] ?? '',
      email: map['email'] ?? '',
      nama: map['nama'] ?? '',
      role: map['role'] ?? '',
    );
  }

  // Fungsi untuk mengirim data ke API (jika diperlukan untuk update profil)
  Map<String, dynamic> toMap() {
    return {
      'iduser': iduser,
      'email': email,
      'nama': nama,
      'role': role,
    };
  }
}