import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baby_model.dart';

class BabyStorageService {
  static const String _babiesKey = 'babies_list';
  static const String _activeBabyIdKey = 'active_baby_id';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  static BabyStorageService? _instance;
  static BabyStorageService get instance =>
      _instance ??= BabyStorageService._();

  BabyStorageService._();

  /// Yeni bebek ekle
  Future<bool> addBaby(BabyModel baby) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Mevcut bebekleri getir
      final babies = await getAllBabies();

      // Eğer ilk bebek ise aktif yap
      final isFirstBaby = babies.isEmpty;
      final newBaby = baby.copyWith(
        id: baby.id.isEmpty ? BabyModel.generateId() : baby.id,
        isActive: isFirstBaby,
      );

      babies.add(newBaby);

      // Listeyi kaydet
      final babiesJson = babies.map((b) => b.toJson()).toList();
      final success = await prefs.setString(
        _babiesKey,
        json.encode(babiesJson),
      );

      // Eğer ilk bebek ise aktif bebek olarak ayarla ve onboarding tamamla
      if (success && isFirstBaby) {
        await prefs.setString(_activeBabyIdKey, newBaby.id);
        await prefs.setBool(_onboardingCompleteKey, true);
      }

      return success;
    } catch (e) {
      print('Bebek eklenemedi: $e');
      return false;
    }
  }

  /// Tüm bebekleri getir
  Future<List<BabyModel>> getAllBabies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final babiesJson = prefs.getString(_babiesKey);

      if (babiesJson != null) {
        final babiesList = json.decode(babiesJson) as List<dynamic>;
        return babiesList
            .map(
              (babyMap) => BabyModel.fromJson(babyMap as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      print('Bebekler okunamadı: $e');
      return [];
    }
  }

  /// Aktif bebeği getir
  Future<BabyModel?> getActiveBaby() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeBabyId = prefs.getString(_activeBabyIdKey);

      if (activeBabyId != null) {
        final babies = await getAllBabies();
        return babies.firstWhere(
          (baby) => baby.id == activeBabyId,
          orElse:
              () =>
                  babies.isNotEmpty
                      ? babies.first
                      : throw Exception('No baby found'),
        );
      }

      // Aktif bebek ID'si yoksa ilk bebeği döndür
      final babies = await getAllBabies();
      return babies.isNotEmpty ? babies.first : null;
    } catch (e) {
      print('Aktif bebek okunamadı: $e');
      return null;
    }
  }

  /// Aktif bebeği ayarla
  Future<bool> setActiveBaby(String babyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_activeBabyIdKey, babyId);
    } catch (e) {
      print('Aktif bebek ayarlanamadı: $e');
      return false;
    }
  }

  /// Bebeği güncelle
  Future<bool> updateBaby(BabyModel updatedBaby) async {
    try {
      final babies = await getAllBabies();
      final index = babies.indexWhere((baby) => baby.id == updatedBaby.id);

      if (index != -1) {
        babies[index] = updatedBaby;

        final prefs = await SharedPreferences.getInstance();
        final babiesJson = babies.map((b) => b.toJson()).toList();
        return await prefs.setString(_babiesKey, json.encode(babiesJson));
      }

      return false;
    } catch (e) {
      print('Bebek güncellenemedi: $e');
      return false;
    }
  }

  /// Bebeği sil
  Future<bool> deleteBaby(String babyId) async {
    try {
      final babies = await getAllBabies();
      babies.removeWhere((baby) => baby.id == babyId);

      final prefs = await SharedPreferences.getInstance();
      final babiesJson = babies.map((b) => b.toJson()).toList();
      final success = await prefs.setString(
        _babiesKey,
        json.encode(babiesJson),
      );

      // Silinen bebek aktif bebek ise yeni aktif bebek seç
      final activeBabyId = prefs.getString(_activeBabyIdKey);
      if (activeBabyId == babyId && babies.isNotEmpty) {
        await prefs.setString(_activeBabyIdKey, babies.first.id);
      } else if (babies.isEmpty) {
        await prefs.remove(_activeBabyIdKey);
        await prefs.remove(_onboardingCompleteKey);
      }

      return success;
    } catch (e) {
      print('Bebek silinemedi: $e');
      return false;
    }
  }

  /// Onboarding tamamlandı mı?
  Future<bool> isOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompleteKey) ?? false;
    } catch (e) {
      print('Onboarding durumu okunamadı: $e');
      return false;
    }
  }

  /// Bebek var mı kontrol et
  Future<bool> hasBaby() async {
    final babies = await getAllBabies();
    return babies.isNotEmpty;
  }

  /// Bebek sayısını getir
  Future<int> getBabyCount() async {
    final babies = await getAllBabies();
    return babies.length;
  }

  /// Tüm veriyi sil (reset)
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success1 = await prefs.remove(_babiesKey);
      final success2 = await prefs.remove(_activeBabyIdKey);
      final success3 = await prefs.remove(_onboardingCompleteKey);
      return success1 && success2 && success3;
    } catch (e) {
      print('Veriler temizlenemedi: $e');
      return false;
    }
  }

  // Backward compatibility - eski getBaby metodu
  @Deprecated('Use getActiveBaby() instead')
  Future<BabyModel?> getBaby() async {
    return await getActiveBaby();
  }

  // Backward compatibility - eski saveBaby metodu
  @Deprecated('Use addBaby() instead')
  Future<bool> saveBaby(BabyModel baby) async {
    return await addBaby(baby);
  }

  /// Debugging için tüm veriler
  Future<Map<String, dynamic>> getAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final babies = await getAllBabies();
      final activeBaby = await getActiveBaby();
      final onboardingComplete = await isOnboardingComplete();

      return {
        'babies': babies.map((b) => b.toJson()).toList(),
        'active_baby': activeBaby?.toJson(),
        'baby_count': babies.length,
        'onboarding_complete': onboardingComplete,
        'stored_keys': prefs.getKeys().toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
