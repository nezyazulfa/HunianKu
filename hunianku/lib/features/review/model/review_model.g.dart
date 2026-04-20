// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewModelAdapter extends TypeAdapter<ReviewModel> {
  @override
  final int typeId = 4;

  @override
  ReviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewModel(
      id: fields[0] as String?,
      idreview: fields[1] as String,
      user: fields[2] as UserModel?,
      kost: fields[3] as KostModel?,
      rating: fields[4] as String,
      komentar: fields[5] as String,
      tanggal: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idreview)
      ..writeByte(2)
      ..write(obj.user)
      ..writeByte(3)
      ..write(obj.kost)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.komentar)
      ..writeByte(6)
      ..write(obj.tanggal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
