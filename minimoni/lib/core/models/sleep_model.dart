import 'package:hive/hive.dart';

part 'sleep_model.g.dart';

@HiveType(typeId: 3)
class SleepModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime? endTime;

  @HiveField(4)
  final SleepType type;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final SleepQuality? quality;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  SleepModel({
    required this.id,
    required this.babyId,
    required this.startTime,
    this.endTime,
    required this.type,
    this.notes,
    this.quality,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SleepModel.create({
    required String babyId,
    required DateTime startTime,
    required SleepType type,
    String? notes,
    SleepQuality? quality,
  }) {
    final now = DateTime.now();
    return SleepModel(
      id: 'sleep_${now.millisecondsSinceEpoch}',
      babyId: babyId,
      startTime: startTime,
      type: type,
      notes: notes,
      quality: quality,
      createdAt: now,
      updatedAt: now,
    );
  }

  SleepModel copyWith({
    String? id,
    String? babyId,
    DateTime? startTime,
    DateTime? endTime,
    SleepType? type,
    String? notes,
    SleepQuality? quality,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      quality: quality ?? this.quality,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Uyku süresi hesapla
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  // Uyku devam ediyor mu?
  bool get isActive {
    return endTime == null;
  }

  // Uyku süresini string olarak getir
  String get durationString {
    if (duration == null) return 'Devam ediyor';

    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    } else {
      return '${minutes}dk';
    }
  }

  // Uyku kalitesi emoji'si
  String get qualityEmoji {
    switch (quality) {
      case SleepQuality.excellent:
        return '😴';
      case SleepQuality.good:
        return '😊';
      case SleepQuality.fair:
        return '😐';
      case SleepQuality.poor:
        return '😢';
      case null:
        return '😴';
    }
  }

  @override
  String toString() {
    return 'SleepModel{id: $id, babyId: $babyId, startTime: $startTime, endTime: $endTime, type: $type, duration: $durationString}';
  }
}

@HiveType(typeId: 4)
enum SleepType {
  @HiveField(0)
  nightSleep('Gece Uykusu', '🌙'),

  @HiveField(1)
  dayNap('Gündüz Uykusu', '☀️'),

  @HiveField(2)
  morningNap('Sabah Uykusu', '🌅'),

  @HiveField(3)
  eveningNap('Akşam Uykusu', '🌆');

  const SleepType(this.displayName, this.emoji);

  final String displayName;
  final String emoji;
}

@HiveType(typeId: 5)
enum SleepQuality {
  @HiveField(0)
  excellent('Mükemmel', '⭐⭐⭐⭐⭐'),

  @HiveField(1)
  good('İyi', '⭐⭐⭐⭐'),

  @HiveField(2)
  fair('Orta', '⭐⭐⭐'),

  @HiveField(3)
  poor('Kötü', '⭐⭐');

  const SleepQuality(this.displayName, this.stars);

  final String displayName;
  final String stars;
}
