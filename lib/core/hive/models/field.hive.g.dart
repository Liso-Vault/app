// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveLisoFieldAdapter extends TypeAdapter<HiveLisoField> {
  @override
  final int typeId = 2;

  @override
  HiveLisoField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveLisoField(
      identifier: fields[0] as String,
      type: fields[1] as String,
      reserved: fields[2] as bool,
      data: (fields[3] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoField obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.reserved)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveLisoFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
