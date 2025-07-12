import 'package:hive/hive.dart';

part 'badge_model.g.dart';

@HiveType(typeId: 1)
class BadgeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final BadgeType type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String emoji;

  @HiveField(6)
  final DateTime earnedAt;

  @HiveField(7)
  final bool isViewed;

  @HiveField(8)
  final int level; // Rozet seviyesi (Bronze, Silver, Gold gibi)

  BadgeModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.earnedAt,
    this.isViewed = false,
    this.level = 1,
  });

  BadgeModel copyWith({
    String? id,
    String? babyId,
    BadgeType? type,
    String? title,
    String? description,
    String? emoji,
    DateTime? earnedAt,
    bool? isViewed,
    int? level,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      earnedAt: earnedAt ?? this.earnedAt,
      isViewed: isViewed ?? this.isViewed,
      level: level ?? this.level,
    );
  }

  static String generateId() {
    return 'badge_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'type': type.name,
      'title': title,
      'description': description,
      'emoji': emoji,
      'earnedAt': earnedAt.toIso8601String(),
      'isViewed': isViewed,
      'level': level,
    };
  }

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'],
      babyId: json['babyId'],
      type: BadgeType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      emoji: json['emoji'],
      earnedAt: DateTime.parse(json['earnedAt']),
      isViewed: json['isViewed'] ?? false,
      level: json['level'] ?? 1,
    );
  }
}

@HiveType(typeId: 2)
enum BadgeType {
  @HiveField(0)
  firstFeeding, // İlk beslenme

  @HiveField(1)
  welcome, // Hoş geldin

  @HiveField(2)
  consistentTracker, // Düzenli takipçi (7 gün)

  @HiveField(3)
  feedingMaster, // Beslenme ustası (30 feeding)

  @HiveField(4)
  weeklyChampion, // Haftalık şampiyon

  @HiveField(5)
  monthlyHero, // Aylık kahraman

  @HiveField(6)
  miniMoniFamily, // MiniMoni ailesi

  @HiveField(7)
  sleepExpert, // Uyku uzmanı

  @HiveField(8)
  growthTracker, // Gelişim takipçisi

  @HiveField(9)
  photoMemory, // Fotoğraf anıları

  @HiveField(10)
  specialMoment, // Özel anlar
}

// Badge tanımları
class BadgeDefinitions {
  static const Map<BadgeType, BadgeConfig> configs = {
    BadgeType.welcome: BadgeConfig(
      title: 'Hoş Geldin! 👋',
      description: 'MiniMoni ailesine katıldığın için teşekkürler!',
      emoji: '🎉',
      requirement: 'İlk kez giriş yap',
    ),
    BadgeType.firstFeeding: BadgeConfig(
      title: 'İlk Beslenme 🍼',
      description: 'İlk beslenme kaydını başarıyla ekledin!',
      emoji: '🥇',
      requirement: '1 beslenme kaydı',
    ),
    BadgeType.consistentTracker: BadgeConfig(
      title: 'Düzenli Takipçi 📅',
      description: '7 gün üst üste takip yaptın, harikasın!',
      emoji: '🏆',
      requirement: '7 gün üst üste kayıt',
    ),
    BadgeType.feedingMaster: BadgeConfig(
      title: 'Beslenme Ustası 💪',
      description: '30 beslenme kaydı tamamladın!',
      emoji: '🌟',
      requirement: '30 beslenme kaydı',
    ),
    BadgeType.weeklyChampion: BadgeConfig(
      title: 'Haftalık Şampiyon 🏅',
      description: 'Bu hafta çok aktiftin!',
      emoji: '🔥',
      requirement: 'Haftada 20+ aktivite',
    ),
    BadgeType.miniMoniFamily: BadgeConfig(
      title: 'MiniMoni Ailesi 💕',
      description: '1 haftadır MiniMoni\'yi kullanıyorsun!',
      emoji: '👨‍👩‍👧‍👦',
      requirement: '7 gün app kullanımı',
    ),
  };
}

class BadgeConfig {
  final String title;
  final String description;
  final String emoji;
  final String requirement;

  const BadgeConfig({
    required this.title,
    required this.description,
    required this.emoji,
    required this.requirement,
  });
}
