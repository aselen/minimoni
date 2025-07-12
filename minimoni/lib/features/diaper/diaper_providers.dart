import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/diaper_change_model.dart';
import '../../core/services/diaper_change_storage_service.dart';
import '../../core/providers/baby_providers.dart';

// Diaper changes for baby provider
final diaperChangesProvider =
    FutureProvider.family<List<DiaperChangeModel>, String>((ref, babyId) async {
      return await DiaperChangeStorageService.instance.getDiaperChangesForBaby(
        babyId,
      );
    });

// Today's diaper changes provider
final todayDiaperChangesProvider =
    FutureProvider.family<List<DiaperChangeModel>, String>((ref, babyId) async {
      return await DiaperChangeStorageService.instance.getTodayDiaperChanges(
        babyId,
      );
    });

// Diaper change stats provider
final diaperStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, babyId) async {
    return await DiaperChangeStorageService.instance.getDiaperChangeStats(
      babyId,
    );
  },
);

// Recent diaper changes provider (limited)
final recentDiaperChangesProvider =
    FutureProvider.family<List<DiaperChangeModel>, String>((ref, babyId) async {
      return await DiaperChangeStorageService.instance.getDiaperChangesForBaby(
        babyId,
        limit: 10,
      );
    });

// Diaper form state provider
class DiaperFormState {
  final DiaperType selectedType;
  final DateTime selectedDateTime;
  final bool isHistoricalEntry;
  final String notes;

  const DiaperFormState({
    this.selectedType = DiaperType.wet,
    required this.selectedDateTime,
    this.isHistoricalEntry = false,
    this.notes = '',
  });

  DiaperFormState copyWith({
    DiaperType? selectedType,
    DateTime? selectedDateTime,
    bool? isHistoricalEntry,
    String? notes,
  }) {
    return DiaperFormState(
      selectedType: selectedType ?? this.selectedType,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      isHistoricalEntry: isHistoricalEntry ?? this.isHistoricalEntry,
      notes: notes ?? this.notes,
    );
  }
}

// Diaper form state notifier
class DiaperFormNotifier extends StateNotifier<DiaperFormState> {
  DiaperFormNotifier()
    : super(DiaperFormState(selectedDateTime: DateTime.now()));

  void updateType(DiaperType type) {
    state = state.copyWith(selectedType: type);
  }

  void updateDateTime(DateTime dateTime) {
    state = state.copyWith(selectedDateTime: dateTime);
  }

  void toggleHistoricalEntry() {
    final newValue = !state.isHistoricalEntry;
    state = state.copyWith(
      isHistoricalEntry: newValue,
      selectedDateTime: newValue ? state.selectedDateTime : DateTime.now(),
    );
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void reset() {
    state = DiaperFormState(selectedDateTime: DateTime.now());
  }
}

// Diaper form provider
final diaperFormProvider =
    StateNotifierProvider<DiaperFormNotifier, DiaperFormState>((ref) {
      return DiaperFormNotifier();
    });

// Add diaper change action provider
final addDiaperChangeProvider = FutureProvider.family<bool, DiaperChangeModel>((
  ref,
  diaperChange,
) async {
  final success = await DiaperChangeStorageService.instance.addDiaperChange(
    diaperChange,
  );

  if (success) {
    // Invalidate related providers to refresh data
    ref.invalidate(diaperChangesProvider);
    ref.invalidate(todayDiaperChangesProvider);
    ref.invalidate(diaperStatsProvider);
    ref.invalidate(recentDiaperChangesProvider);
  }

  return success;
});

// Delete diaper change action provider
final deleteDiaperChangeProvider = FutureProvider.family<bool, String>((
  ref,
  diaperChangeId,
) async {
  final success = await DiaperChangeStorageService.instance.deleteDiaperChange(
    diaperChangeId,
  );

  if (success) {
    // Invalidate related providers to refresh data
    ref.invalidate(diaperChangesProvider);
    ref.invalidate(todayDiaperChangesProvider);
    ref.invalidate(diaperStatsProvider);
    ref.invalidate(recentDiaperChangesProvider);
  }

  return success;
});

// Time since last change provider
final timeSinceLastChangeProvider = FutureProvider.family<Duration?, String>((
  ref,
  babyId,
) async {
  return await DiaperChangeStorageService.instance.getTimeSinceLastChange(
    babyId,
  );
});

// Diaper changes by type provider
final diaperChangesByTypeProvider = FutureProvider.family<
  List<DiaperChangeModel>,
  ({String babyId, DiaperType type})
>((ref, params) async {
  return await DiaperChangeStorageService.instance.getDiaperChangesByType(
    params.babyId,
    params.type,
  );
});

// Diaper changes by date range provider
final diaperChangesByDateRangeProvider = FutureProvider.family<
  List<DiaperChangeModel>,
  ({String babyId, DateTime startDate, DateTime endDate})
>((ref, params) async {
  return await DiaperChangeStorageService.instance.getDiaperChangesByDateRange(
    params.babyId,
    params.startDate,
    params.endDate,
  );
});
