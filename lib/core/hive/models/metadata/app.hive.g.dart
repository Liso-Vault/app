// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMetadataAppAdapter extends TypeAdapter<HiveMetadataApp> {
  @override
  final int typeId = 11;

  @override
  HiveMetadataApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMetadataApp(
      appName: fields[0] as String,
      packageName: fields[1] as String,
      version: fields[2] as String,
      buildNumber: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveMetadataApp obj) {
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
      other is HiveMetadataAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
