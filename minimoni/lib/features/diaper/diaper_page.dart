import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/models/baby_model.dart';
import '../../core/services/baby_storage_service.dart';
import '../../core/models/diaper_change_model.dart';
import '../../core/services/diaper_change_storage_service.dart';
import '../../shared/widgets/modern_header.dart';

/// Alt Değişimi Takip Sayfası
/// Modern header ve responsive tasarım ile alt değişimi ekleme ve geçmiş görüntüleme
class DiaperPage extends ConsumerStatefulWidget {
  const DiaperPage({super.key});

  @override
  ConsumerState<DiaperPage> createState() => _DiaperPageState();
}

class _DiaperPageState extends ConsumerState<DiaperPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _heroController;
  late AnimationController _cardController;

  // Animations
  late Animation<double> _heroAnimation;
  late Animation<double> _cardAnimation;

  // State
  BabyModel? _baby;
  bool _isLoading = true;
  bool _hasNewRecord = false;
  List<DiaperChangeModel> _todayChanges = [];
  List<DiaperChangeModel> _recentChanges = [];
  Map<String, dynamic> _stats = {};

  // Form state
  DiaperType _selectedType = DiaperType.wet;
  DateTime _selectedDateTime = DateTime.now();
  bool _isHistoricalEntry = false;
  TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    _startAnimations();
  }

  void _initAnimations() {
    // Hero animation
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Card stagger animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Setup animations
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutBack,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );
  }

  void _startAnimations() {
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
  }

  void _loadData() async {
    final baby = await BabyStorageService.instance.getActiveBaby();

    if (baby != null) {
      final todayChanges = await DiaperChangeStorageService.instance
          .getTodayDiaperChanges(baby.id);
      final recentChanges = await DiaperChangeStorageService.instance
          .getDiaperChangesForBaby(baby.id, limit: 10);
      final stats = await DiaperChangeStorageService.instance
          .getDiaperChangeStats(baby.id);

      if (mounted) {
        setState(() {
          _baby = baby;
          _todayChanges = todayChanges;
          _recentChanges = recentChanges;
          _stats = stats;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F4FF), // Light purple
              Color(0xFFFFF8F8), // Light pink
              Color(0xFFF0F8E8), // Light mint
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? _buildLoadingState()
                  : CustomScrollView(
                    slivers: [
                      ModernHeader(
                        title: 'Alt Değişimi',
                        emoji: '🧷',
                        showBackButton: true,
                        onBackPressed: () => context.pop(_hasNewRecord),
                        isDashboard: false,
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (_baby != null) ...[
                              _buildHeroSection(),
                              const SizedBox(height: 20),
                              _buildDiaperTypeSelector(),
                              const SizedBox(height: 20),
                              _buildDateTimeSelector(),
                              const SizedBox(height: 20),
                              _buildNoteSection(),
                              const SizedBox(height: 20),
                              _buildActionButtons(),
                              const SizedBox(height: 30),
                              _buildTodayStats(),
                              const SizedBox(height: 20),
                              _buildRecentHistory(),
                            ] else
                              _buildNoBabyState(),
                            const SizedBox(height: 50),
                          ]),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
          ),
          SizedBox(height: 16),
          Text(
            'Alt değişimi verileri yükleniyor...',
            style: TextStyle(color: AppColors.textMedium, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _heroAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFE4E1), // Light pink
                        Color(0xFFF0F8E8), // Light mint
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: const Color(0xFFE6E6FA).withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _baby!.genderEmoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_baby!.name}\'nin Alt Değişimi',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Temiz ve sağlıklı büyüme için düzenli takip 🧷',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                      ),
                      if (_stats['timeSinceLastMinutes'] != null &&
                          _stats['timeSinceLastMinutes'] > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Son değişim: ${_stats['timeSinceLastHours']} saat önce',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiaperTypeSelector() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E1).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.baby_changing_station,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Alt Değişimi Tipi',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3.0,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children:
                      DiaperType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primaryPink.withOpacity(0.1)
                                      : const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primaryPink
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  type.emoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    type.displayName,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? AppColors.primaryPink
                                              : AppColors.textDark,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateTimeSelector() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E1).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Zaman Seçimi',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: [Expanded(child: _buildTimeToggle())]),
                if (_isHistoricalEntry) ...[
                  const SizedBox(height: 16),
                  _buildDateTimePickers(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isHistoricalEntry = false;
                  _selectedDateTime = DateTime.now();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      !_isHistoricalEntry ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      !_isHistoricalEntry
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color:
                          !_isHistoricalEntry
                              ? AppColors.primaryPink
                              : AppColors.textLight,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Şimdi',
                      style: TextStyle(
                        color:
                            !_isHistoricalEntry
                                ? AppColors.primaryPink
                                : AppColors.textLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isHistoricalEntry = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isHistoricalEntry ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      _isHistoricalEntry
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color:
                          _isHistoricalEntry
                              ? AppColors.primaryPink
                              : AppColors.textLight,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Geçmiş',
                      style: TextStyle(
                        color:
                            _isHistoricalEntry
                                ? AppColors.primaryPink
                                : AppColors.textLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          _selectedDateTime.hour,
                          _selectedDateTime.minute,
                        );
                      });
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textDark,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          _selectedDateTime.year,
                          _selectedDateTime.month,
                          _selectedDateTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.textDark,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E1).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.note_alt,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Not (Opsiyonel)',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Örn: Yeni bez markası denendi, normal kıvam...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F8F8),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveDiaperChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kaydet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayStats() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E1).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Bugünkü İstatistikler',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.0,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _buildStatCard('💧', 'Islak', '${_stats['todayWet'] ?? 0}'),
                    _buildStatCard(
                      '💩',
                      'Kirli',
                      '${_stats['todayDirty'] ?? 0}',
                    ),
                    _buildStatCard(
                      '💧💩',
                      'İkisi de',
                      '${_stats['todayBoth'] ?? 0}',
                    ),
                    _buildStatCard(
                      '✨',
                      'Temiz',
                      '${_stats['todayClean'] ?? 0}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.today,
                        color: AppColors.primaryPink,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Toplam: ${_stats['todayCount'] ?? 0} değişim',
                        style: const TextStyle(
                          color: AppColors.primaryPink,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory() {
    if (_recentChanges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Henüz alt değişimi kaydı yok',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E1).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Son Değişimler',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...(_recentChanges
                    .take(5)
                    .map((change) => _buildHistoryItem(change))
                    .toList()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(DiaperChangeModel change) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(change.type.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  change.type.displayName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  change.timeAgo,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
                if (change.notes != null && change.notes!.isNotEmpty)
                  Text(
                    change.notes!,
                    style: const TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBabyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.baby_changing_station,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Önce bebek profili oluşturun',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Alt değişimi takibi için bebek bilgilerini girmeniz gerekiyor.',
              style: TextStyle(color: AppColors.textMedium, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDiaperChange() async {
    if (_baby == null) return;

    final diaperChange = DiaperChangeModel.create(
      babyId: _baby!.id,
      timestamp: _selectedDateTime,
      type: _selectedType,
      notes:
          _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
    );

    final success = await DiaperChangeStorageService.instance.addDiaperChange(
      diaperChange,
    );

    if (success) {
      setState(() {
        _hasNewRecord = true;
        _noteController.clear();
        _selectedType = DiaperType.wet;
        _selectedDateTime = DateTime.now();
        _isHistoricalEntry = false;
      });

      _loadData(); // Refresh data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Alt değişimi kaydedildi: ${diaperChange.type.displayName}',
                ),
              ],
            ),
            backgroundColor: AppColors.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Kayıt sırasında hata oluştu'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
