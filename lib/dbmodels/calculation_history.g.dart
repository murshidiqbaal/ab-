// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculation_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalculationHistoryAdapter extends TypeAdapter<CalculationHistory> {
  @override
  final int typeId = 15;

  @override
  CalculationHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalculationHistory(
      question: fields[12] as String,
      answer: fields[1] as String,
      date: fields[2] as DateTime,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CalculationHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(12)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.answer)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
