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
      identifier: fields[0] as String,
      category: fields[1] as String,
      title: fields[2] as String,
      iconUrl: fields[3] as String,
      fields: (fields[4] as List).cast<HiveLisoField>(),
      favorite: fields[5] as bool,
      protected: fields[6] as bool,
      tags: (fields[7] as List).cast<String>(),
      metadata: fields[8] as HiveMetadata,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.iconUrl)
      ..writeByte(4)
      ..write(obj.fields)
      ..writeByte(5)
      ..write(obj.favorite)
      ..writeByte(6)
      ..write(obj.protected)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
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
