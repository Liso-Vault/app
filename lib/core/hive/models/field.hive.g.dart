// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveLisoFieldAdapter extends TypeAdapter<HiveLisoField> {
  @override
  final int typeId = 20;

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
      required: fields[3] as bool,
      readOnly: fields[4] as bool,
      data: fields[5] as HiveLisoFieldData,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoField obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.reserved)
      ..writeByte(3)
      ..write(obj.required)
      ..writeByte(4)
      ..write(obj.readOnly)
      ..writeByte(5)
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

class HiveLisoFieldDataAdapter extends TypeAdapter<HiveLisoFieldData> {
  @override
  final int typeId = 21;

  @override
  HiveLisoFieldData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveLisoFieldData(
      label: fields[0] as String?,
      hint: fields[1] as String?,
      value: fields[2] as String?,
      choices: (fields[3] as List?)?.cast<HiveLisoFieldChoices>(),
      extra: (fields[4] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoFieldData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.hint)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.choices)
      ..writeByte(4)
      ..write(obj.extra);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveLisoFieldDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveLisoFieldChoicesAdapter extends TypeAdapter<HiveLisoFieldChoices> {
  @override
  final int typeId = 22;

  @override
  HiveLisoFieldChoices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveLisoFieldChoices(
      name: fields[0] as String,
      value: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveLisoFieldChoices obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveLisoFieldChoicesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
