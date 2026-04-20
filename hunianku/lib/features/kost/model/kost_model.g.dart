// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kost_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KostModelAdapter extends TypeAdapter<KostModel> {
  @override
  final int typeId = 1;

  @override
  KostModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KostModel(
      id: fields[0] as String?,
      idkost: fields[1] as String,
      namakost: fields[2] as String,
      jenis: fields[3] as String,
      alamat: fields[4] as String,
      lokasi: fields[5] as String,
      harga: fields[6] as String,
      kontak: fields[7] as String,
      daftarfasilitas: fields[8] as String,
      deskripsi: fields[9] as String,
      status: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KostModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idkost)
      ..writeByte(2)
      ..write(obj.namakost)
      ..writeByte(3)
      ..write(obj.jenis)
      ..writeByte(4)
      ..write(obj.alamat)
      ..writeByte(5)
      ..write(obj.lokasi)
      ..writeByte(6)
      ..write(obj.harga)
      ..writeByte(7)
      ..write(obj.kontak)
      ..writeByte(8)
      ..write(obj.daftarfasilitas)
      ..writeByte(9)
      ..write(obj.deskripsi)
      ..writeByte(10)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KostModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
