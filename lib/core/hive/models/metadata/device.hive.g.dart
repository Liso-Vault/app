// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMetadataDeviceAdapter extends TypeAdapter<HiveMetadataDevice> {
  @override
  final int typeId = 222;

  @override
  HiveMetadataDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMetadataDevice(
      id: fields[0] as String,
      name: fields[1] as String?,
      model: fields[2] as String,
      platform: fields[3] as String,
      osVersion: fields[4] as String,
      info: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveMetadataDevice obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.platform)
      ..writeByte(4)
      ..write(obj.osVersion)
      ..writeByte(5)
      ..write(obj.info);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMetadataDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
