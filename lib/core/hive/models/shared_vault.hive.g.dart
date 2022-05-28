// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_vault.hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSharedVaultAdapter extends TypeAdapter<HiveSharedVault> {
  @override
  final int typeId = 30;

  @override
  HiveSharedVault read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSharedVault(
      id: fields[0] as String,
      cipherKey: fields[1] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSharedVault obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cipherKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSharedVaultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
