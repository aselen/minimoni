// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepModelAdapter extends TypeAdapter<SleepModel> {
  @override
  final int typeId = 3;

  @override
  SleepModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      type: fields[4] as SleepType,
      notes: fields[5] as String?,
      quality: fields[6] as SleepQuality?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SleepModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.quality)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SleepTypeAdapter extends TypeAdapter<SleepType> {
  @override
  final int typeId = 4;

  @override
  SleepType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SleepType.nightSleep;
      case 1:
        return SleepType.dayNap;
      case 2:
        return SleepType.morningNap;
      case 3:
        return SleepType.eveningNap;
      default:
        return SleepType.nightSleep;
    }
  }

  @override
  void write(BinaryWriter writer, SleepType obj) {
    switch (obj) {
      case SleepType.nightSleep:
        writer.writeByte(0);
        break;
      case SleepType.dayNap:
        writer.writeByte(1);
        break;
      case SleepType.morningNap:
        writer.writeByte(2);
        break;
      case SleepType.eveningNap:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SleepQualityAdapter extends TypeAdapter<SleepQuality> {
  @override
  final int typeId = 5;

  @override
  SleepQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SleepQuality.excellent;
      case 1:
        return SleepQuality.good;
      case 2:
        return SleepQuality.fair;
      case 3:
        return SleepQuality.poor;
      default:
        return SleepQuality.excellent;
    }
  }

  @override
  void write(BinaryWriter writer, SleepQuality obj) {
    switch (obj) {
      case SleepQuality.excellent:
        writer.writeByte(0);
        break;
      case SleepQuality.good:
        writer.writeByte(1);
        break;
      case SleepQuality.fair:
        writer.writeByte(2);
        break;
      case SleepQuality.poor:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
