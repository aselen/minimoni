import '../models/badge_model.dart';
import '../models/feeding_model.dart';
import 'badge_storage_service.dart';
import 'feeding_storage_service.dart';

class BadgeManagerService {
  static BadgeManagerService? _instance;
  static BadgeManagerService get instance {
    _instance ??= BadgeManagerService._();
    return _instance!;
  }

  BadgeManagerService._();

  // Badge kazanma kontrolleri
  Future<List<BadgeModel>> checkAndAwardBadges(String babyId) async {
    final newBadges = <BadgeModel>[];

    // Tüm badge türlerini kontrol et
    for (final badgeType in BadgeType.values) {
      final hasAlready = await BadgeStorageService.instance.hasBadgeType(
        babyId,
        badgeType,
      );
      if (!hasAlready) {
        final shouldAward = await _shouldAwardBadge(babyId, badgeType);
        if (shouldAward) {
          final badge = await _createBadge(babyId, badgeType);
          if (badge != null) {
            final success = await BadgeStorageService.instance.addBadge(badge);
            if (success) {
              newBadges.add(badge);
            }
          }
        }
      }
    }

    return newBadges;
  }

  // Belirli bir badge türü için kontrol
  Future<bool> _shouldAwardBadge(String babyId, BadgeType type) async {
    switch (type) {
      case BadgeType.welcome:
        return await _checkWelcomeBadge(babyId);

      case BadgeType.firstFeeding:
        return await _checkFirstFeedingBadge(babyId);

      case BadgeType.consistentTracker:
        return await _checkConsistentTrackerBadge(babyId);

      case BadgeType.feedingMaster:
        return await _checkFeedingMasterBadge(babyId);

      case BadgeType.weeklyChampion:
        return await _checkWeeklyChampionBadge(babyId);

      case BadgeType.miniMoniFamily:
        return await _checkMiniMoniFamilyBadge(babyId);

      default:
        return false;
    }
  }

  // Badge oluşturma
  Future<BadgeModel?> _createBadge(String babyId, BadgeType type) async {
    final config = BadgeDefinitions.configs[type];
    if (config == null) return null;

    return BadgeModel(
      id: BadgeModel.generateId(),
      babyId: babyId,
      type: type,
      title: config.title,
      description: config.description,
      emoji: config.emoji,
      earnedAt: DateTime.now(),
    );
  }

  // Badge kontrol metodları

  Future<bool> _checkWelcomeBadge(String babyId) async {
    // İlk kez app kullanımı (basit kontrol)
    return true; // Her bebek için otomatik verilir
  }

  Future<bool> _checkFirstFeedingBadge(String babyId) async {
    final feedings = await FeedingStorageService.instance
        .getRecentFeedingsForBaby(babyId, limit: 1);
    return feedings.isNotEmpty;
  }

  Future<bool> _checkConsistentTrackerBadge(String babyId) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final feedings = await FeedingStorageService.instance
        .getRecentFeedingsForBaby(babyId, limit: 100);

    // Son 7 günde her gün en az 1 feeding var mı?
    for (int i = 0; i < 7; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final hasFeedingOnDay = feedings.any(
        (feeding) =>
            feeding.timestamp.day == checkDate.day &&
            feeding.timestamp.month == checkDate.month &&
            feeding.timestamp.year == checkDate.year,
      );

      if (!hasFeedingOnDay) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _checkFeedingMasterBadge(String babyId) async {
    final feedings = await FeedingStorageService.instance
        .getRecentFeedingsForBaby(babyId, limit: 50);
    return feedings.length >= 30;
  }

  Future<bool> _checkWeeklyChampionBadge(String babyId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final feedings = await FeedingStorageService.instance
        .getRecentFeedingsForBaby(babyId, limit: 100);
    final thisWeekFeedings =
        feedings.where((f) => f.timestamp.isAfter(weekAgo)).length;

    return thisWeekFeedings >= 20; // Bu hafta 20+ beslenme
  }

  Future<bool> _checkMiniMoniFamilyBadge(String babyId) async {
    final feedings = await FeedingStorageService.instance
        .getRecentFeedingsForBaby(babyId, limit: 100);
    if (feedings.isEmpty) return false;

    final firstFeeding = feedings.last; // En eski feeding
    final daysSinceFirst =
        DateTime.now().difference(firstFeeding.timestamp).inDays;

    return daysSinceFirst >= 7; // 1 haftadır kullanıyor
  }

  // Feeding sonrası badge kontrolü (async olarak çağrılacak)
  Future<List<BadgeModel>> checkBadgesAfterFeeding(String babyId) async {
    return await checkAndAwardBadges(babyId);
  }

  // Manuel badge verme (admin/test için)
  Future<bool> awardBadgeManually(String babyId, BadgeType type) async {
    final hasAlready = await BadgeStorageService.instance.hasBadgeType(
      babyId,
      type,
    );
    if (hasAlready) return false;

    final badge = await _createBadge(babyId, type);
    if (badge != null) {
      return await BadgeStorageService.instance.addBadge(badge);
    }
    return false;
  }

  // Badge bildirim formatı
  String getBadgeNotificationText(BadgeModel badge) {
    return '🎉 Yeni rozet kazandın!\n\n${badge.emoji} ${badge.title}\n\n${badge.description}';
  }

  // Badge'ların öncelik sırası (notification için)
  int getBadgePriority(BadgeType type) {
    switch (type) {
      case BadgeType.welcome:
        return 10;
      case BadgeType.firstFeeding:
        return 9;
      case BadgeType.consistentTracker:
        return 8;
      case BadgeType.feedingMaster:
        return 7;
      case BadgeType.weeklyChampion:
        return 6;
      case BadgeType.miniMoniFamily:
        return 5;
      default:
        return 1;
    }
  }
}
