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
      mainSubscription: fields[1] as String,
      subSubscription: fields[2] as String?,
      address: fields[3] as String,
      lat: fields[4] as double,
      lng: fields[5] as double,
      altitude: fields[6] as double?,
      accuracy: fields[7] as double?,
      imagePath: fields[8] as String?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mainSubscription)
      ..writeByte(2)
      ..write(obj.subSubscription)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.lat)
      ..writeByte(5)
      ..write(obj.lng)
      ..writeByte(6)
      ..write(obj.altitude)
      ..writeByte(7)
      ..write(obj.accuracy)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
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
