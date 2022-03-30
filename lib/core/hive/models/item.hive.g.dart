// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveLisoItemAdapter extends TypeAdapter<HiveLisoItem> {
  @override
  final int typeId = 1;

  @override
  HiveLisoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveLisoItem(
      icon: fields[0] as String,
      title: fields[1] as String,
      fields: (fields[2] as List).cast<HiveLisoField>(),
      tags: (fields[3] as List).cast<String>(),
      metadata: fields[4] as HiveMetadata,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.icon)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.fields)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveLisoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
