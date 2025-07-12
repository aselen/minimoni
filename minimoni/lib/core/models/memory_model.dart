import 'package:hive/hive.dart';

part 'memory_model.g.dart';

@HiveType(typeId: 9)
class MemoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final String? photoPath;

  @HiveField(5)
  final MoodType mood;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final List<String> tags;

  @HiveField(8)
  final bool isFavorite;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  MemoryModel({
    required this.id,
    required this.babyId,
    required this.title,
    this.note,
    this.photoPath,
    required this.mood,
    required this.timestamp,
    this.tags = const [],
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemoryModel.create({
    required String babyId,
    required String title,
    String? note,
    String? photoPath,
    required MoodType mood,
    required DateTime timestamp,
    List<String> tags = const [],
    bool isFavorite = false,
  }) {
    final now = DateTime.now();
    return MemoryModel(
      id: 'memory_${now.millisecondsSinceEpoch}',
      babyId: babyId,
      title: title,
      note: note,
      photoPath: photoPath,
      mood: mood,
      timestamp: timestamp,
      tags: tags,
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
    );
  }

  MemoryModel copyWith({
    String? id,
    String? babyId,
    String? title,
    String? note,
    String? photoPath,
    MoodType? mood,
    DateTime? timestamp,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      title: title ?? this.title,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      mood: mood ?? this.mood,
      timestamp: timestamp ?? this.timestamp,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    }
  }

  // Tarih formatı
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  // Foto var mı kontrolü
  bool get hasPhoto {
    return photoPath != null && photoPath!.isNotEmpty;
  }

  // Not var mı kontrolü
  bool get hasNote {
    return note != null && note!.isNotEmpty;
  }

  // Display için kısa not
  String get shortNote {
    if (!hasNote) return 'Not eklenmemiş';
    if (note!.length <= 100) return note!;
    return '${note!.substring(0, 100)}...';
  }

  @override
  String toString() {
    return 'MemoryModel{id: $id, babyId: $babyId, title: $title, mood: $mood, timestamp: $timestamp}';
  }
}

@HiveType(typeId: 10)
enum MoodType {
  @HiveField(0)
  veryHappy('Çok Mutlu', '😍', 'Harika bir gün!'),

  @HiveField(1)
  happy('Mutlu', '😊', 'Güzel anlar'),

  @HiveField(2)
  neutral('Normal', '😐', 'Sıradan bir gün'),

  @HiveField(3)
  tired('Yorgun', '😴', 'Biraz yorgunluk var'),

  @HiveField(4)
  fussy('Huysuz', '😢', 'Zor bir gün'),

  @HiveField(5)
  excited('Heyecanlı', '🤩', 'Çok eğlenceli!'),

  @HiveField(6)
  peaceful('Huzurlu', '😌', 'Sakin ve huzurlu'),

  @HiveField(7)
  playful('Oyuncu', '😄', 'Oyun zamanı!'),

  @HiveField(8)
  sleepy('Uykulu', '😪', 'Uyku vakti yaklaşıyor'),

  @HiveField(9)
  curious('Meraklı', '🤔', 'Keşfetmeye hazır');

  const MoodType(this.displayName, this.emoji, this.description);

  final String displayName;
  final String emoji;
  final String description;

  // Ruh hali kategorilerine göre gruplama
  static List<MoodType> get positiveModels => [
    veryHappy,
    happy,
    excited,
    peaceful,
    playful,
    curious,
  ];

  static List<MoodType> get neutralMoods => [neutral];

  static List<MoodType> get negativeMoods => [tired, fussy];

  static List<MoodType> get sleepyMoods => [sleepy, tired];
}
