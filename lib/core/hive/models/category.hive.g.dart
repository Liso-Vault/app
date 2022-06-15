// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveLisoCategoryAdapter extends TypeAdapter<HiveLisoCategory> {
  @override
  final int typeId = 11;

  @override
  HiveLisoCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveLisoCategory(
      id: fields[0] as String,
      iconUrl: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String,
      significant: fields[4] as String,
      fields: (fields[5] as List).cast<HiveLisoField>(),
      reserved: fields[6] as bool,
      deleted: fields[8] as bool?,
      metadata: fields[7] as HiveMetadata?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoCategory obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.iconUrl)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.significant)
      ..writeByte(5)
      ..write(obj.fields)
      ..writeByte(6)
      ..write(obj.reserved)
      ..writeByte(8)
      ..write(obj.deleted)
      ..writeByte(7)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveLisoCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
