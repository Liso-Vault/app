// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveAppAdapter extends TypeAdapter<HiveApp> {
  @override
  final int typeId = 11;

  @override
  HiveApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveApp(
      appName: fields[0] as String,
      packageName: fields[1] as String,
      version: fields[2] as String,
      buildNumber: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveApp obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.appName)
      ..writeByte(1)
      ..write(obj.packageName)
      ..writeByte(2)
      ..write(obj.version)
      ..writeByte(3)
      ..write(obj.buildNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
