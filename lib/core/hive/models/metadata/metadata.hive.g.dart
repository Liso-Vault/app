// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMetadataAdapter extends TypeAdapter<HiveMetadata> {
  @override
  final int typeId = 10;

  @override
  HiveMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMetadata(
      device: fields[0] as HiveMetadataDevice,
      app: fields[1] as HiveMetadataApp,
      createdTime: fields[2] as DateTime,
      updatedTime: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HiveMetadata obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.device)
      ..writeByte(1)
      ..write(obj.app)
      ..writeByte(2)
      ..write(obj.createdTime)
      ..writeByte(3)
      ..write(obj.updatedTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
