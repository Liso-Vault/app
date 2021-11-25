// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seed.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSeedAdapter extends TypeAdapter<HiveSeed> {
  @override
  final int typeId = 0;

  @override
  HiveSeed read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSeed(
      seed: fields[0] as String,
      address: fields[1] as String,
      description: fields[2] as String,
      ledger: fields[3] as String,
      origin: fields[4] as String,
      metadata: fields[5] as HiveMetadata,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSeed obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.seed)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.ledger)
      ..writeByte(4)
      ..write(obj.origin)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSeedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
