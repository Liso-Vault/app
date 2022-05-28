// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveLisoItemAdapter extends TypeAdapter<HiveLisoItem> {
  @override
  final int typeId = 0;

  @override
  HiveLisoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveLisoItem(
      identifier: fields[0] as String,
      groupId: fields[1] as String,
      category: fields[2] as String,
      title: fields[3] as String,
      iconUrl: fields[4] as String,
      fields: (fields[5] as List).cast<HiveLisoField>(),
      favorite: fields[6] as bool,
      protected: fields[7] as bool,
      trashed: fields[8] as bool,
      deleted: fields[9] as bool,
      tags: (fields[10] as List).cast<String>(),
      sharedTags: (fields[11] as List).cast<String>(),
      attachments: (fields[12] as List).cast<String>(),
      metadata: fields[13] as HiveMetadata,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.iconUrl)
      ..writeByte(5)
      ..write(obj.fields)
      ..writeByte(6)
      ..write(obj.favorite)
      ..writeByte(7)
      ..write(obj.protected)
      ..writeByte(8)
      ..write(obj.trashed)
      ..writeByte(9)
      ..write(obj.deleted)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.sharedTags)
      ..writeByte(12)
      ..write(obj.attachments)
      ..writeByte(13)
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
