import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:hunianku/features/auth/model/user_model.dart';
import 'package:hunianku/features/dashboard/model/kost_model.dart';

part 'review_model.g.dart';

@HiveType(typeId: 4)
class ReviewModel {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String idreview;
  @HiveField(2)
  final UserModel? user;
  @HiveField(3)
  final KostModel? kost;
  @HiveField(4)
  final String rating;
  @HiveField(5)
  final String komentar;
  @HiveField(6)
  final String tanggal;
  ReviewModel({
    this.id,
    required this.idreview,
    this.user, 
    this.kost,
    required this.rating,
    required this.komentar,
    required this.tanggal,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['_id'] != null ? (map['_id'] as ObjectId).oid : null,
      idreview: map['idreview'] ?? '',
      user: map['user'] != null ? UserModel.fromMap(map['user']) : null,
      kost: map['kost'] != null ? KostModel.fromMap(map['kost']) : null,
      rating: map['rating']?.toString() ?? '5', 
      komentar: map['komentar'] ?? '',
      tanggal: map['tanggal'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id' : id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'idreview': idreview,
      'user': user?.toMap(),
      'kost': kost?.toMap(),
      'rating': rating,
      'komentar': komentar,
      'tanggal': tanggal,
    };
  }
}
