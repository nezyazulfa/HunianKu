import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'kost_model.g.dart';

@HiveType(typeId: 1)
class KostModel {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String idkost;
  @HiveField(2)
  final String iduser;
  @HiveField(3)
  final String namakost;
  @HiveField(4)
  final String jenis;
  @HiveField(5)
  final String alamat;
  @HiveField(6)
  final String lokasi;
  @HiveField(7)
  final String harga;
  @HiveField(8)
  final String kontak;
  @HiveField(9)
  final String daftarfasilitas;
  @HiveField(10)
  final String deskripsi;
  @HiveField(11)
  final String status;
  KostModel({
    this.id,
    required this.idkost,
    required this.iduser,
    required this.namakost,
    required this.jenis,
    required this.alamat,
    required this.lokasi,
    required this.harga,
    required this.kontak,
    required this.daftarfasilitas,
    required this.deskripsi,
    required this.status,
  });

  factory KostModel.fromMap(Map<String, dynamic> map) {
    return KostModel(
      id: map['_id'] != null ? (map['_id'] as ObjectId).oid : null,
      idkost: map['idkost'] ?? '',
      iduser: map['iduser'] ?? '',
      namakost: map['namakost'] ?? '',
      jenis: map['jenis'] ?? '',
      alamat: map['alamat'] ?? '',
      lokasi: map['lokasi'] ?? '',
      harga: map['harga']?.toString() ?? '',
      kontak: map['kontak'] ?? '',
      daftarfasilitas: map['daftarfasilitas'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id' : id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'idkost': idkost,
      'iduser': iduser,
      'namakost': namakost,
      'jenis': jenis,
      'alamat': alamat,
      'lokasi': lokasi,
      'harga': harga,
      'kontak': kontak,
      'daftarfasilitas': daftarfasilitas,
      'deskripsi': deskripsi,
      'status': status,
    };
  }
}
