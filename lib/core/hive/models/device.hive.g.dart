// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveDeviceAdapter extends TypeAdapter<HiveDevice> {
  @override
  final int typeId = 12;

  @override
  HiveDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDevice(
      id: fields[0] as String,
      model: fields[1] as String,
      unit: fields[2] as String,
      platform: fields[3] as String,
      osVersion: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveDevice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.model)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.platform)
      ..writeByte(4)
      ..write(obj.osVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
