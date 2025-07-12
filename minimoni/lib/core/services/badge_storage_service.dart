import 'package:hive_flutter/hive_flutter.dart';
import '../models/badge_model.dart';

class BadgeStorageService {
  static const String _boxName = 'badges';
  static Box<BadgeModel>? _box;

  static BadgeStorageService? _instance;
  static BadgeStorageService get instance {
    _instance ??= BadgeStorageService._();
    return _instance!;
  }

  BadgeStorageService._();

  static Future<void> initialize() async {
    _box = Hive.box<BadgeModel>(_boxName);
  }

  Box<BadgeModel> get _badgeBox {
    if (_box == null || !_box!.isOpen) {
      // Fallback to get box if not initialized
      _box = Hive.box<BadgeModel>(_boxName);
      if (_box == null || !_box!.isOpen) {
        throw Exception('Badge box is not initialized');
      }
    }
    return _box!;
  }

  // Badge ekleme
  Future<bool> addBadge(BadgeModel badge) async {
    try {
      await _badgeBox.put(badge.id, badge);
      return true;
    } catch (e) {
      print('Error adding badge: $e');
      return false;
    }
  }

  // Belirli bebeğin rozetlerini getir
  Future<List<BadgeModel>> getBadgesForBaby(String babyId) async {
    try {
      final badges =
          _badgeBox.values.where((badge) => badge.babyId == babyId).toList();

      // Tarihe göre sırala (en yeni önce)
      badges.sort((a, b) => b.earnedAt.compareTo(a.earnedAt));
      return badges;
    } catch (e) {
      print('Error getting badges for baby: $e');
      return [];
    }
  }

  // Henüz görülmemiş rozetleri getir
  Future<List<BadgeModel>> getUnviewedBadges(String babyId) async {
    try {
      final badges = await getBadgesForBaby(babyId);
      return badges.where((badge) => !badge.isViewed).toList();
    } catch (e) {
      print('Error getting unviewed badges: $e');
      return [];
    }
  }

  // Rozeti görüldü olarak işaretle
  Future<bool> markBadgeAsViewed(String badgeId) async {
    try {
      final badge = _badgeBox.get(badgeId);
      if (badge != null) {
        final updatedBadge = badge.copyWith(isViewed: true);
        await _badgeBox.put(badgeId, updatedBadge);
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking badge as viewed: $e');
      return false;
    }
  }

  // Belirli tip rozet var mı kontrol et
  Future<bool> hasBadgeType(String babyId, BadgeType type) async {
    try {
      final badges = await getBadgesForBaby(babyId);
      return badges.any((badge) => badge.type == type);
    } catch (e) {
      print('Error checking badge type: $e');
      return false;
    }
  }

  // Son kazanılan rozet
  Future<BadgeModel?> getLatestBadge(String babyId) async {
    try {
      final badges = await getBadgesForBaby(babyId);
      if (badges.isNotEmpty) {
        return badges.first; // Zaten tarihe göre sıralı
      }
      return null;
    } catch (e) {
      print('Error getting latest badge: $e');
      return null;
    }
  }

  // Badge istatistikleri
  Future<Map<String, int>> getBadgeStats(String babyId) async {
    try {
      final badges = await getBadgesForBaby(babyId);
      return {
        'total': badges.length,
        'unviewed': badges.where((b) => !b.isViewed).length,
        'thisWeek':
            badges
                .where((b) => DateTime.now().difference(b.earnedAt).inDays <= 7)
                .length,
        'thisMonth':
            badges
                .where(
                  (b) => DateTime.now().difference(b.earnedAt).inDays <= 30,
                )
                .length,
      };
    } catch (e) {
      print('Error getting badge stats: $e');
      return {'total': 0, 'unviewed': 0, 'thisWeek': 0, 'thisMonth': 0};
    }
  }

  // Tüm rozetleri sil (sadece test için)
  Future<bool> clearAllBadges() async {
    try {
      await _badgeBox.clear();
      return true;
    } catch (e) {
      print('Error clearing badges: $e');
      return false;
    }
  }

  // Belirli rozetleri sil
  Future<bool> deleteBadge(String badgeId) async {
    try {
      await _badgeBox.delete(badgeId);
      return true;
    } catch (e) {
      print('Error deleting badge: $e');
      return false;
    }
  }
}
