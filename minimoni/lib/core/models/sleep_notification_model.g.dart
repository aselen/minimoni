// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepNotificationModelAdapter
    extends TypeAdapter<SleepNotificationModel> {
  @override
  final int typeId = 11;

  @override
  SleepNotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepNotificationModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      type: fields[2] as NotificationType,
      title: fields[3] as String,
      message: fields[4] as String,
      createdAt: fields[5] as DateTime,
      scheduledFor: fields[6] as DateTime?,
      isRead: fields[7] as bool,
      isActive: fields[8] as bool,
      metadata: (fields[9] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SleepNotificationModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.scheduledFor)
      ..writeByte(7)
      ..write(obj.isRead)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepNotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 12;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.sleepReminder;
      case 1:
        return NotificationType.sleepPattern;
      case 2:
        return NotificationType.sleepMilestone;
      case 3:
        return NotificationType.sleepWarning;
      case 4:
        return NotificationType.sleepTip;
      default:
        return NotificationType.sleepReminder;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.sleepReminder:
        writer.writeByte(0);
        break;
      case NotificationType.sleepPattern:
        writer.writeByte(1);
        break;
      case NotificationType.sleepMilestone:
        writer.writeByte(2);
        break;
      case NotificationType.sleepWarning:
        writer.writeByte(3);
        break;
      case NotificationType.sleepTip:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
