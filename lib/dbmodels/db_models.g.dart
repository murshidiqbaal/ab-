// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryAdapter extends TypeAdapter<Memory> {
  @override
  final int typeId = 2;

  @override
  Memory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Memory(
      imagePath: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Memory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
