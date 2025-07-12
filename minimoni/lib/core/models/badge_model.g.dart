// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BadgeModelAdapter extends TypeAdapter<BadgeModel> {
  @override
  final int typeId = 1;

  @override
  BadgeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      type: fields[2] as BadgeType,
      title: fields[3] as String,
      description: fields[4] as String,
      emoji: fields[5] as String,
      earnedAt: fields[6] as DateTime,
      isViewed: fields[7] as bool,
      level: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.emoji)
      ..writeByte(6)
      ..write(obj.earnedAt)
      ..writeByte(7)
      ..write(obj.isViewed)
      ..writeByte(8)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeTypeAdapter extends TypeAdapter<BadgeType> {
  @override
  final int typeId = 2;

  @override
  BadgeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BadgeType.firstFeeding;
      case 1:
        return BadgeType.welcome;
      case 2:
        return BadgeType.consistentTracker;
      case 3:
        return BadgeType.feedingMaster;
      case 4:
        return BadgeType.weeklyChampion;
      case 5:
        return BadgeType.monthlyHero;
      case 6:
        return BadgeType.miniMoniFamily;
      case 7:
        return BadgeType.sleepExpert;
      case 8:
        return BadgeType.growthTracker;
      case 9:
        return BadgeType.photoMemory;
      case 10:
        return BadgeType.specialMoment;
      default:
        return BadgeType.firstFeeding;
    }
  }

  @override
  void write(BinaryWriter writer, BadgeType obj) {
    switch (obj) {
      case BadgeType.firstFeeding:
        writer.writeByte(0);
        break;
      case BadgeType.welcome:
        writer.writeByte(1);
        break;
      case BadgeType.consistentTracker:
        writer.writeByte(2);
        break;
      case BadgeType.feedingMaster:
        writer.writeByte(3);
        break;
      case BadgeType.weeklyChampion:
        writer.writeByte(4);
        break;
      case BadgeType.monthlyHero:
        writer.writeByte(5);
        break;
      case BadgeType.miniMoniFamily:
        writer.writeByte(6);
        break;
      case BadgeType.sleepExpert:
        writer.writeByte(7);
        break;
      case BadgeType.growthTracker:
        writer.writeByte(8);
        break;
      case BadgeType.photoMemory:
        writer.writeByte(9);
        break;
      case BadgeType.specialMoment:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
