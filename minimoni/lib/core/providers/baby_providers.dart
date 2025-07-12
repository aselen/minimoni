import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/baby_model.dart';
import '../services/baby_storage_service.dart';

// Baby Storage Service Provider
final babyStorageServiceProvider = Provider<BabyStorageService>((ref) {
  return BabyStorageService.instance;
});

// All Babies Provider
final allBabiesProvider = FutureProvider<List<BabyModel>>((ref) async {
  final service = ref.read(babyStorageServiceProvider);
  return await service.getAllBabies();
});

// Active Baby Provider
final activeBabyProvider = FutureProvider<BabyModel?>((ref) async {
  final service = ref.read(babyStorageServiceProvider);
  return await service.getActiveBaby();
});

// Baby Count Provider
final babyCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(babyStorageServiceProvider);
  return await service.getBabyCount();
});

// Has Baby Provider
final hasBabyProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(babyStorageServiceProvider);
  return await service.hasBaby();
});

// Onboarding Complete Provider
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(babyStorageServiceProvider);
  return await service.isOnboardingComplete();
});

// Baby Operations Provider
class BabyOperations {
  final BabyStorageService _service;
  final Ref _ref;

  BabyOperations(this._service, this._ref);

  Future<bool> addBaby(BabyModel baby) async {
    final success = await _service.addBaby(baby);
    if (success) {
      _ref.invalidate(allBabiesProvider);
      _ref.invalidate(activeBabyProvider);
      _ref.invalidate(babyCountProvider);
      _ref.invalidate(hasBabyProvider);
      _ref.invalidate(onboardingCompleteProvider);
    }
    return success;
  }

  Future<bool> updateBaby(BabyModel baby) async {
    final success = await _service.updateBaby(baby);
    if (success) {
      _ref.invalidate(allBabiesProvider);
      _ref.invalidate(activeBabyProvider);
    }
    return success;
  }

  Future<bool> deleteBaby(String babyId) async {
    final success = await _service.deleteBaby(babyId);
    if (success) {
      _ref.invalidate(allBabiesProvider);
      _ref.invalidate(activeBabyProvider);
      _ref.invalidate(babyCountProvider);
      _ref.invalidate(hasBabyProvider);
      _ref.invalidate(onboardingCompleteProvider);
    }
    return success;
  }

  Future<bool> setActiveBaby(String babyId) async {
    final success = await _service.setActiveBaby(babyId);
    if (success) {
      _ref.invalidate(activeBabyProvider);
      _ref.invalidate(allBabiesProvider);
    }
    return success;
  }

  Future<bool> clearAllData() async {
    final success = await _service.clearAllData();
    if (success) {
      _ref.invalidate(allBabiesProvider);
      _ref.invalidate(activeBabyProvider);
      _ref.invalidate(babyCountProvider);
      _ref.invalidate(hasBabyProvider);
      _ref.invalidate(onboardingCompleteProvider);
    }
    return success;
  }
}

final babyOperationsProvider = Provider<BabyOperations>((ref) {
  final service = ref.read(babyStorageServiceProvider);
  return BabyOperations(service, ref);
});

// Baby Selection State
class BabySelectionState {
  final BabyModel? selectedBaby;
  final bool isLoading;
  final String? error;

  const BabySelectionState({
    this.selectedBaby,
    this.isLoading = false,
    this.error,
  });

  BabySelectionState copyWith({
    BabyModel? selectedBaby,
    bool? isLoading,
    String? error,
  }) {
    return BabySelectionState(
      selectedBaby: selectedBaby ?? this.selectedBaby,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BabySelectionNotifier extends StateNotifier<BabySelectionState> {
  final BabyOperations _operations;

  BabySelectionNotifier(this._operations) : super(const BabySelectionState());

  Future<void> selectBaby(String babyId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _operations.setActiveBaby(babyId);
      if (success) {
        // Provider'lar otomatik olarak güncellenecek
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Bebek seçilemedi');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Hata: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final babySelectionProvider =
    StateNotifierProvider<BabySelectionNotifier, BabySelectionState>((ref) {
      final operations = ref.read(babyOperationsProvider);
      return BabySelectionNotifier(operations);
    });
