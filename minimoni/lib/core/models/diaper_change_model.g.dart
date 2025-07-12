// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diaper_change_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaperChangeModelAdapter extends TypeAdapter<DiaperChangeModel> {
  @override
  final int typeId = 6;

  @override
  DiaperChangeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaperChangeModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      type: fields[3] as DiaperType,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DiaperChangeModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaperChangeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DiaperTypeAdapter extends TypeAdapter<DiaperType> {
  @override
  final int typeId = 7;

  @override
  DiaperType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DiaperType.wet;
      case 1:
        return DiaperType.dirty;
      case 2:
        return DiaperType.both;
      case 3:
        return DiaperType.clean;
      default:
        return DiaperType.wet;
    }
  }

  @override
  void write(BinaryWriter writer, DiaperType obj) {
    switch (obj) {
      case DiaperType.wet:
        writer.writeByte(0);
        break;
      case DiaperType.dirty:
        writer.writeByte(1);
        break;
      case DiaperType.both:
        writer.writeByte(2);
        break;
      case DiaperType.clean:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaperTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
