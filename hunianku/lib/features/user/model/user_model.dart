import 'package:mongo_dart/mongo_dart.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  String? id;
  @HiveField(1)
  final String iduser;
  @HiveField(2)
  final String password;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String nama;
  @HiveField(5)
  final String role;
  @HiveField(6)
  UserModel({
    this.id,
    required this.iduser,
    required this.password,
    required this.email,
    required this.nama,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] as ObjectId?)?.oid,
      iduser: map['iduser'],
      password: map['password'],
      email: map['email'],
      nama: map['nama'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'iduser': iduser,
      'password': password,
      'email': email,
      'nama': nama,
      'role': role,
    };
  }
}
