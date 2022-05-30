// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveLisoGroupAdapter extends TypeAdapter<HiveLisoGroup> {
  @override
  final int typeId = 10;

  @override
  HiveLisoGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveLisoGroup(
      id: fields[0] as String,
      iconUrl: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String,
      metadata: fields[4] as HiveMetadata?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoGroup obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.iconUrl)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveLisoGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
