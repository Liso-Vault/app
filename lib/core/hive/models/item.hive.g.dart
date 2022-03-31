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
      type: fields[0] as String,
      icon: fields[1] as Uint8List,
      title: fields[2] as String,
      fields: (fields[3] as List).cast<HiveLisoField>(),
      tags: (fields[4] as List).cast<String>(),
      metadata: fields[5] as HiveMetadata,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.fields)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
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
