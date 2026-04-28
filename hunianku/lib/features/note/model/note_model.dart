import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:hunianku/features/user/model/user_model.dart';
import 'package:hunianku/features/kost/model/kost_model.dart';

part 'note_model.g.dart';

@HiveType(typeId: 3)
class NoteModel {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String idnote;
  @HiveField(2)
  final UserModel? user;
  @HiveField(3)
  final KostModel? kost;
  @HiveField(4)
  final String catatan;
  NoteModel({
    this.id,
    required this.idnote,
    this.user, 
    this.kost,
    required this.catatan,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: (map['_id'] as ObjectId).oid,
      idnote: map['idnote'] ?? '',
      user: map['user'] != null ? UserModel.fromMap(map['user']) : null,
      kost: map['kost'] != null ? KostModel.fromMap(map['kost']) : null,
      catatan: map['catatan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id' : id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'idnote': idnote,
      'user': user?.toMap(),
      'kost': kost?.toMap(),
      'catatan': catatan,
    };
  }
}
