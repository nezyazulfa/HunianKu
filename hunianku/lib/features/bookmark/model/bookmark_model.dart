import 'package:mongo_dart/mongo_dart.dart';
import 'package:hive/hive.dart';
import 'package:hunianku/features/user/model/user_model.dart';
import 'package:hunianku/features/kost/model/kost_model.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 2)
class BookmarkModel {
  @HiveField(0)
  String? id;
  @HiveField(1)
  final String idbookmark;
  @HiveField(2)
  final UserModel? user;   
  @HiveField(3)
  final KostModel? kost;
  @HiveField(4)
  final String tanggal;
  BookmarkModel({
    this.id,
    required this.idbookmark,
    this.user, 
    this.kost,
    required this.tanggal,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: (map['_id'] as ObjectId?)?.oid,
      idbookmark: map['idbookmark'],
      user: map['user'] != null ? UserModel.fromMap(map['user']) : null,
      kost: map['kost'] != null ? KostModel.fromMap(map['kost']) : null,
      tanggal: map['tanggal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'idbookmark': idbookmark,
      'user': user?.toMap(),
      'kost': kost?.toMap(),
      'tanggal': tanggal,
    };
  }
}
