import 'package:hive/hive.dart';

part 'diaper_change_model.g.dart';

@HiveType(typeId: 6)
class DiaperChangeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final DiaperType type;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  DiaperChangeModel({
    required this.id,
    required this.babyId,
    required this.timestamp,
    required this.type,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiaperChangeModel.create({
    required String babyId,
    required DateTime timestamp,
    required DiaperType type,
    String? notes,
  }) {
    final now = DateTime.now();
    return DiaperChangeModel(
      id: 'diaper_${now.millisecondsSinceEpoch}',
      babyId: babyId,
      timestamp: timestamp,
      type: type,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  DiaperChangeModel copyWith({
    String? id,
    String? babyId,
    DateTime? timestamp,
    DiaperType? type,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaperChangeModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Zaman önce string'i
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  // Display için not metni
  String get displayNote {
    if (notes != null && notes!.isNotEmpty) {
      return notes!;
    }
    return type.defaultNote;
  }

  @override
  String toString() {
    return 'DiaperChangeModel{id: $id, babyId: $babyId, timestamp: $timestamp, type: $type}';
  }
}

@HiveType(typeId: 7)
enum DiaperType {
  @HiveField(0)
  wet('Islak', '💧', 'Sadece idrar'),

  @HiveField(1)
  dirty('Kirli', '💩', 'Sadece dışkı'),

  @HiveField(2)
  both('İkisi de', '💧💩', 'İdrar ve dışkı'),

  @HiveField(3)
  clean('Temiz', '✨', 'Temiz bez kontrolü');

  const DiaperType(this.displayName, this.emoji, this.defaultNote);

  final String displayName;
  final String emoji;
  final String defaultNote;
}
