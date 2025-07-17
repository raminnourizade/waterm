// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingModelAdapter extends TypeAdapter<ReadingModel> {
  @override
  final int typeId = 0;

  @override
  ReadingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingModel(
      id: fields[0] as String,
      subscriptionNumber: fields[1] as String,
      phone: fields[2] as String,
      description: fields[3] as String,
      lat: fields[4] as double,
      lng: fields[5] as double,
      imagePath: fields[6] as String?,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subscriptionNumber)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.lat)
      ..writeByte(5)
      ..write(obj.lng)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
