// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_domain.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveAppDomainAdapter extends TypeAdapter<HiveAppDomain> {
  @override
  final int typeId = 30;

  @override
  HiveAppDomain read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAppDomain(
      title: fields[0] as String,
      iconUrl: fields[1] as String,
      domains: (fields[2] as List).cast<HiveDomain>(),
      appIds: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveAppDomain obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.iconUrl)
      ..writeByte(2)
      ..write(obj.domains)
      ..writeByte(3)
      ..write(obj.appIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAppDomainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveDomainAdapter extends TypeAdapter<HiveDomain> {
  @override
  final int typeId = 31;

  @override
  HiveDomain read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDomain();
  }

  @override
  void write(BinaryWriter writer, HiveDomain obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDomainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
