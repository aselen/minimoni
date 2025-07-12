import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/models/baby_model.dart';
import '../../core/providers/baby_providers.dart';

class BabySelector extends ConsumerWidget {
  final bool showAddButton;
  final VoidCallback? onAddBaby;
  final bool compact;

  const BabySelector({
    Key? key,
    this.showAddButton = true,
    this.onAddBaby,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babiesAsync = ref.watch(allBabiesProvider);
    final activeBabyAsync = ref.watch(activeBabyProvider);
    final selectionState = ref.watch(babySelectionProvider);

    return babiesAsync.when(
      data: (babies) {
        if (babies.isEmpty) {
          return _buildEmptyState(context);
        }

        return activeBabyAsync.when(
          data: (activeBaby) {
            if (activeBaby == null) {
              return _buildEmptyState(context);
            }

            return _buildBabySelector(
              context,
              ref,
              babies,
              activeBaby,
              selectionState,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Hata: $e'),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Hata: $e'),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.baby_changing_station,
              color: AppColors.primaryPink,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Henüz bebek eklenmemiş',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
          ),
          if (showAddButton)
            IconButton(
              onPressed: onAddBaby,
              icon: const Icon(Icons.add, color: AppColors.primaryPink),
              tooltip: 'Bebek Ekle',
            ),
        ],
      ),
    );
  }

  Widget _buildBabySelector(
    BuildContext context,
    WidgetRef ref,
    List<BabyModel> babies,
    BabyModel activeBaby,
    BabySelectionState selectionState,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activeBaby.genderEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeBaby.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      activeBaby.ageString,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (showAddButton)
                IconButton(
                  onPressed: onAddBaby,
                  icon: const Icon(Icons.add, color: AppColors.primaryPink),
                  tooltip: 'Bebek Ekle',
                ),
              IconButton(
                onPressed:
                    () => _showBabySelectionDialog(
                      context,
                      ref,
                      babies,
                      activeBaby,
                    ),
                icon: const Icon(
                  Icons.swap_horiz,
                  color: AppColors.primaryPink,
                ),
                tooltip: 'Bebek Değiştir',
              ),
            ],
          ),
          if (babies.length > 1 && !compact) ...[
            const SizedBox(height: 8),
            _buildBabyList(context, ref, babies, activeBaby),
          ],
        ],
      ),
    );
  }

  Widget _buildBabyList(
    BuildContext context,
    WidgetRef ref,
    List<BabyModel> babies,
    BabyModel activeBaby,
  ) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: babies.length,
        itemBuilder: (context, index) {
          final baby = babies[index];
          final isActive = baby.id == activeBaby.id;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectBaby(ref, baby.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive ? AppColors.primaryPink : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isActive ? AppColors.primaryPink : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      baby.genderEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      baby.name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectBaby(WidgetRef ref, String babyId) {
    final selectionNotifier = ref.read(babySelectionProvider.notifier);
    selectionNotifier.selectBaby(babyId);
  }

  void _showBabySelectionDialog(
    BuildContext context,
    WidgetRef ref,
    List<BabyModel> babies,
    BabyModel activeBaby,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Bebek Seç',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: babies.length,
                itemBuilder: (context, index) {
                  final baby = babies[index];
                  final isActive = baby.id == activeBaby.id;

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? AppColors.primaryPink
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        baby.genderEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      baby.name,
                      style: GoogleFonts.inter(
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isActive
                                ? AppColors.primaryPink
                                : AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      baby.ageString,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    trailing:
                        isActive
                            ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryPink,
                            )
                            : null,
                    onTap: () {
                      _selectBaby(ref, baby.id);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
            ],
          ),
    );
  }
}
