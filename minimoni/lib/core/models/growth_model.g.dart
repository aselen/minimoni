// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GrowthModelAdapter extends TypeAdapter<GrowthModel> {
  @override
  final int typeId = 13;

  @override
  GrowthModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      height: fields[2] as double,
      weight: fields[3] as double,
      measurementDate: fields[4] as DateTime,
      notes: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GrowthModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.measurementDate)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
