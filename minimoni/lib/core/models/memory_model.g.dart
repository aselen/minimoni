// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryModelAdapter extends TypeAdapter<MemoryModel> {
  @override
  final int typeId = 9;

  @override
  MemoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      title: fields[2] as String,
      note: fields[3] as String?,
      photoPath: fields[4] as String?,
      mood: fields[5] as MoodType,
      timestamp: fields[6] as DateTime,
      tags: (fields[7] as List).cast<String>(),
      isFavorite: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.photoPath)
      ..writeByte(5)
      ..write(obj.mood)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodTypeAdapter extends TypeAdapter<MoodType> {
  @override
  final int typeId = 10;

  @override
  MoodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodType.veryHappy;
      case 1:
        return MoodType.happy;
      case 2:
        return MoodType.neutral;
      case 3:
        return MoodType.tired;
      case 4:
        return MoodType.fussy;
      case 5:
        return MoodType.excited;
      case 6:
        return MoodType.peaceful;
      case 7:
        return MoodType.playful;
      case 8:
        return MoodType.sleepy;
      case 9:
        return MoodType.curious;
      default:
        return MoodType.veryHappy;
    }
  }

  @override
  void write(BinaryWriter writer, MoodType obj) {
    switch (obj) {
      case MoodType.veryHappy:
        writer.writeByte(0);
        break;
      case MoodType.happy:
        writer.writeByte(1);
        break;
      case MoodType.neutral:
        writer.writeByte(2);
        break;
      case MoodType.tired:
        writer.writeByte(3);
        break;
      case MoodType.fussy:
        writer.writeByte(4);
        break;
      case MoodType.excited:
        writer.writeByte(5);
        break;
      case MoodType.peaceful:
        writer.writeByte(6);
        break;
      case MoodType.playful:
        writer.writeByte(7);
        break;
      case MoodType.sleepy:
        writer.writeByte(8);
        break;
      case MoodType.curious:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
