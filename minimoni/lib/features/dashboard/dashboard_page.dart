import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'dart:async';

import '../../core/constants/colors.dart';
import '../../core/models/baby_model.dart';
import '../../core/services/baby_storage_service.dart';
import '../../core/models/feeding_model.dart';
import '../../core/services/feeding_storage_service.dart';
import '../../core/services/badge_manager_service.dart';
import '../../core/models/badge_model.dart';
import '../../core/services/badge_storage_service.dart';
import '../../core/models/sleep_model.dart';
import '../../core/services/sleep_storage_service.dart';
import '../../core/models/diaper_change_model.dart';
import '../../core/services/diaper_change_storage_service.dart';
import '../../core/models/growth_model.dart';
import '../../core/services/growth_storage_service.dart';
import '../../core/providers/baby_providers.dart';
import '../../shared/widgets/modern_header.dart';
import '../../shared/widgets/baby_selector.dart';
import '../profile/add_baby_page.dart';
import '../memory/memory_providers.dart';

/// Animated Dashboard Page
/// Main home screen with beautiful animations and tracking cards
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _heroController;
  late AnimationController _cardController;
  late AnimationController _miniMoniController;

  // Animations
  late Animation<double> _heroAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _miniMoniFloat;

  // State
  BabyModel? _baby;
  bool _isLoading = true;
  List<FeedingModel> _todayFeedings = [];
  List<BadgeModel> _recentBadges = [];
  List<SleepModel> _todaySleepRecords = [];
  SleepModel? _activeSleep;
  List<DiaperChangeModel> _todayDiaperChanges = [];
  Map<String, dynamic> _diaperStats = {};

  // Timer for real-time updates
  Timer? _refreshTimer;

  // MiniMoni AI önerileri
  final List<String> _aiSuggestions = [
    'Uyku düzeni için yumuşak müzik açmayı deneyin 🎵',
    'Bebeğinizin motor gelişimi için renkli oyuncaklar faydalı 🌈',
    'Bugün tummy time zamanı! 10 dakika yeterli 🤸‍♀️',
    'Besin çeşitliliği için yeni bir sebze deneyin 🥕',
    'Kitap okuma zamanı! Gelişim için çok önemli 📚',
  ];

  late String _currentAiSuggestion;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    _startAnimations();
    _currentAiSuggestion =
        _aiSuggestions[math.Random().nextInt(_aiSuggestions.length)];
  }

  // Refresh method for external calls
  void refreshData() {
    if (mounted) {
      _loadData();
    }
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

    // MiniMoni floating animation
    _miniMoniController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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

    _miniMoniFloat = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _miniMoniController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
    _miniMoniController.repeat(reverse: true);
  }

  void _loadData() async {
    final baby = await BabyStorageService.instance.getActiveBaby();
    List<FeedingModel> todayFeedings = [];
    List<BadgeModel> recentBadges = [];
    List<SleepModel> todaySleepRecords = [];
    SleepModel? activeSleep;
    List<DiaperChangeModel> todayDiaperChanges = [];
    Map<String, dynamic> diaperStats = {};

    if (baby != null) {
      final today = DateTime.now();

      // Beslenme verileri
      final allFeedings = await FeedingStorageService.instance
          .getRecentFeedingsForBaby(baby.id, limit: 50);

      // Bugünkü beslenmeleri filtrele (gün/ay/yıl eşleşmesi)
      todayFeedings =
          allFeedings.where((f) {
            return f.timestamp.day == today.day &&
                f.timestamp.month == today.month &&
                f.timestamp.year == today.year;
          }).toList();

      // Uyku verileri
      todaySleepRecords = await SleepStorageService.instance
          .getTodaySleepRecords(baby.id);
      activeSleep = await SleepStorageService.instance.getActiveSleepRecord(
        baby.id,
      );

      // Debug: Günlük filtrelemeyi kontrol et
      print('📊 Dashboard Data Yüklendi:');
      print('📅 Bugün: ${today.day}/${today.month}/${today.year}');
      print('🍼 Bugünkü beslenme: ${todayFeedings.length}');
      print('😴 Bugünkü uyku: ${todaySleepRecords.length}');
      print('🛌 Aktif uyku: ${activeSleep != null ? 'Evet' : 'Hayır'}');

      // Alt değişimi verileri
      todayDiaperChanges = await DiaperChangeStorageService.instance
          .getTodayDiaperChanges(baby.id);
      diaperStats = await DiaperChangeStorageService.instance
          .getDiaperChangeStats(baby.id);

      // Son 5 rozeti al
      final allBadges = await BadgeStorageService.instance.getBadgesForBaby(
        baby.id,
      );
      recentBadges = allBadges.take(5).toList();
    }

    if (mounted) {
      setState(() {
        _baby = baby;
        _todayFeedings = todayFeedings;
        _recentBadges = recentBadges;
        _todaySleepRecords = todaySleepRecords;
        _activeSleep = activeSleep;
        _todayDiaperChanges = todayDiaperChanges;
        _diaperStats = diaperStats;
        _isLoading = false;
      });

      // Start or stop timer based on active sleep
      if (activeSleep != null) {
        _startRefreshTimer();
      } else {
        _stopRefreshTimer();
      }
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardController.dispose();
    _miniMoniController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8F0), // Çok açık peach/krem
              Color(0xFFFFE4E1), // Misty rose
              Color(0xFFF0F8FF), // Alice blue
              Color(0xFFF5F5DC), // Beige
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              final activeBabyAsync = ref.watch(activeBabyProvider);

              return activeBabyAsync.when(
                data: (activeBaby) {
                  // Aktif bebek değiştiğinde verileri yeniden yükle
                  if (_baby?.id != activeBaby?.id) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadData();
                    });
                  }

                  return _isLoading
                      ? _buildLoadingState()
                      : CustomScrollView(
                        slivers: [
                          ModernHeader(
                            title: 'MiniMoni',
                            subtitle: 'Bebek Takip',
                            emoji: '👶',
                            showProfileButton: true,
                            isDashboard: true,
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                BabySelector(
                                  onAddBaby: () async {
                                    final result = await Navigator.of(
                                      context,
                                    ).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const AddBabyPage(),
                                      ),
                                    );
                                    if (result == true) {
                                      refreshData();
                                    }
                                  },
                                ),
                                const SizedBox(height: 40),
                                _buildWelcomeSection(),
                                const SizedBox(height: 20),
                                _buildDashboardGrid(),
                                const SizedBox(height: 20),
                                if (_recentBadges.isNotEmpty) ...[
                                  _buildBadgeSection(),
                                  const SizedBox(height: 20),
                                ],
                                _buildMiniMoniAssistant(),
                                const SizedBox(height: 20),
                                _buildWeeklyProgress(),
                                const SizedBox(height: 32),
                                _buildMilkAnalysisSummaryCard(context),
                              ]),
                            ),
                          ),
                        ],
                      );
                },
                loading: () => _buildLoadingState(),
                error: (e, s) => Center(child: Text('Hata: $e')),
              );
            },
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
            'MiniMoni hazırlanıyor...',
            style: TextStyle(color: AppColors.textMedium, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _heroAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
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
                // Bebek Fotoğrafı
                AnimatedBuilder(
                  animation: _miniMoniFloat,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _miniMoniFloat.value * 0.5),
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFE4E1), // Soft pembe
                              Color(0xFFFFF0F5), // Lavender blush
                            ],
                          ),
                          borderRadius: BorderRadius.circular(33),
                          border: Border.all(
                            color: const Color(0xFFE6E6FA).withOpacity(0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Bebek fotoğrafı ekleme/değiştirme
                              context.push('/dashboard/profile');
                            },
                            borderRadius: BorderRadius.circular(31),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(31),
                              child:
                                  _baby == null
                                      ? const Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: AppColors.textLight,
                                          size: 30,
                                        ),
                                      )
                                      : Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFFFE4E1),
                                              Color(0xFFF0F8E8),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _baby!.genderEmoji,
                                            style: const TextStyle(
                                              fontSize: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _baby?.parentName != null
                            ? 'Merhaba ${_baby!.parentName}! 👋'
                            : 'Merhaba! 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _baby == null
                            ? 'Bebeğinin fotoğrafını ekle ve takibe başla'
                            : _getPersonalizedBabyMessage(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textMedium,
                          height: 1.4,
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

  Widget _buildDashboardGrid() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Consumer(
            builder: (context, ref, _) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildDashboardCard(
                    '🍼',
                    'Günlük Beslenme',
                    _getFeedingStatus(),
                    const Color(0xFFE6F3FF),
                    () async {
                      final result = await context.push('/dashboard/feeding');
                      if (result == true) {
                        refreshData();
                      }
                    },
                    null,
                  ),
                  _buildDashboardCard(
                    '😴',
                    'Günlük Uyku',
                    _getSleepStatus(),
                    const Color(0xFFE6F7FF),
                    () async {
                      final result = await context.push('/dashboard/sleep');
                      if (result == true) {
                        refreshData();
                      }
                    },
                    null,
                  ),
                  _buildDashboardCard(
                    '🧷',
                    'Alt Değişimi',
                    _getDiaperStatus(),
                    const Color(0xFFF0F8E8),
                    () async {
                      final result = await context.push('/dashboard/diaper');
                      if (result == true) {
                        refreshData();
                      }
                    },
                    null,
                  ),
                  _buildDashboardCard(
                    '📸',
                    'Özel Anlar',
                    _getMemoryStatus(context, ref),
                    const Color(0xFFFFF0F5),
                    () async {
                      final result = await context.push('/dashboard/memory');
                      if (result == true) {
                        refreshData();
                      }
                    },
                    null,
                  ),
                  _buildDashboardCard(
                    '📏',
                    'Gelişim Takibi',
                    _getGrowthStatus(),
                    const Color(0xFFE8F5E8),
                    () async {
                      final result = await context.push(
                        '/dashboard/growth-analysis',
                      );
                      if (result == true) {
                        refreshData();
                      }
                    },
                    null,
                  ),
                  _buildDashboardCard(
                    '🔔',
                    'Bildirimler',
                    _getNotificationStatus(),
                    const Color(0xFFFFF0E6),
                    () async {
                      await context.push('/dashboard/notifications');
                    },
                    null,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBadgeSection() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.15), // Altın rengi
                  const Color(0xFFFFE4B5).withOpacity(0.15), // Moccasin
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
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
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🏆', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Son Kazanılan Rozetler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 76,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentBadges.length,
                    itemBuilder: (context, index) {
                      final badge = _recentBadges[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: _buildBadgeCard(badge),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeCard(BadgeModel badge) {
    return Container(
      width: 68,
      height: 76,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              badge.isViewed
                  ? Colors.grey.withOpacity(0.3)
                  : const Color(0xFFFFD700).withOpacity(0.6),
          width: badge.isViewed ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              badge.title,
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!badge.isViewed) ...[
            const SizedBox(height: 1),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getFeedingStatus() {
    if (_todayFeedings.isEmpty) {
      return 'Bugün henüz kayıt yok\nİlk beslenmeyi ekleyin';
    }

    final lastFeeding = _todayFeedings.first;
    final timeDiff = DateTime.now().difference(lastFeeding.timestamp);
    String lastTime;

    if (timeDiff.inHours > 0) {
      lastTime = '${timeDiff.inHours}s önce';
    } else if (timeDiff.inMinutes > 0) {
      lastTime = '${timeDiff.inMinutes}dk önce';
    } else {
      lastTime = 'Az önce';
    }

    final totalCount = _todayFeedings.length;
    final totalMl = _todayFeedings
        .where((f) => f.amount != null)
        .fold(0, (sum, f) => sum + f.amount!);

    return 'Bugün: $totalCount öğün\nSon: $lastTime • ${totalMl}ml';
  }

  String _getSleepStatus() {
    if (_activeSleep != null) {
      // Şu anda uyuyor
      final duration = DateTime.now().difference(_activeSleep!.startTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      String durationText;
      if (hours > 0) {
        durationText = '${hours}s ${minutes}dk';
      } else {
        durationText = '${minutes}dk';
      }

      return 'Şu anda uyuyor 😴\n${_activeSleep!.type.displayName} • $durationText';
    }

    if (_todaySleepRecords.isEmpty) {
      return 'Bugün henüz uyku kaydı yok\nİlk uykuyu başlatın';
    }

    final lastSleep = _todaySleepRecords.first;
    final timeDiff = DateTime.now().difference(
      lastSleep.endTime ?? lastSleep.startTime,
    );
    String lastTime;

    if (timeDiff.inHours > 0) {
      lastTime = '${timeDiff.inHours}s önce';
    } else if (timeDiff.inMinutes > 0) {
      lastTime = '${timeDiff.inMinutes}dk önce';
    } else {
      lastTime = 'Az önce';
    }

    final totalCount = _todaySleepRecords.length;
    final totalHours =
        _todaySleepRecords
            .where((s) => s.endTime != null)
            .map((s) => s.endTime!.difference(s.startTime).inMinutes)
            .fold(0, (sum, minutes) => sum + minutes) /
        60.0;

    return 'Bugün: $totalCount uyku\nSon: $lastTime • ${totalHours.toStringAsFixed(1)}s';
  }

  String _getDiaperStatus() {
    if (_todayDiaperChanges.isEmpty) {
      return 'Bugün henüz değişim yok\nİlk alt değişimini ekleyin';
    }

    final lastChange = _todayDiaperChanges.first;
    final timeDiff = DateTime.now().difference(lastChange.timestamp);
    String lastTime;

    if (timeDiff.inHours > 0) {
      lastTime = '${timeDiff.inHours}s önce';
    } else if (timeDiff.inMinutes > 0) {
      lastTime = '${timeDiff.inMinutes}dk önce';
    } else {
      lastTime = 'Az önce';
    }

    final totalCount = _todayDiaperChanges.length;
    final wetCount = _diaperStats['todayWet'] ?? 0;
    final dirtyCount = _diaperStats['todayDirty'] ?? 0;

    return 'Bugün: $totalCount değişim\nSon: $lastTime • ${wetCount + dirtyCount} kayıt';
  }

  String _getMemoryStatus(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardMemorySummaryProvider);
    return summary.when(
      data: (data) {
        final total = data['totalCount'] ?? 0;
        final lastTitle = data['lastMemoryTitle'] ?? '';
        if (total == 0) {
          return 'Henüz anı eklenmedi';
        }
        return 'Toplam: $total anı\nSon: $lastTitle';
      },
      loading: () => 'Yükleniyor...',
      error: (e, _) => 'Hata: $e',
    );
  }

  String _getGrowthStatus() {
    // Mock data for now - will be replaced with real data from growth provider
    return 'Boy ve kilo takibi';
  }

  String _getNotificationStatus() {
    if (_baby == null) return 'Bildirim yok';

    // TODO: Gerçek bildirim sayısını al
    return 'Bildirimleri görüntüle';
  }

  String _getPersonalizedBabyMessage() {
    if (_baby == null) return '';

    final now = DateTime.now();
    final hour = now.hour;
    final babyName = _baby!.name;
    final emoji = _baby!.genderEmoji;
    final ageInMonths = _baby!.ageInMonths;

    // Günün saatine göre mesaj
    String timeMessage;
    if (hour < 6) {
      timeMessage = 'Güzel bir sabah olsun';
    } else if (hour < 12) {
      timeMessage = 'Güzel bir gün olsun';
    } else if (hour < 18) {
      timeMessage = 'Güzel bir öğleden sonra olsun';
    } else {
      timeMessage = 'Güzel bir akşam olsun';
    }

    // Yaşa göre mesaj
    String ageMessage;
    if (ageInMonths < 3) {
      ageMessage = 'Yeni doğan dönemi';
    } else if (ageInMonths < 6) {
      ageMessage = 'Bebeklik dönemi';
    } else if (ageInMonths < 12) {
      ageMessage = 'Büyüme dönemi';
    } else if (ageInMonths < 24) {
      ageMessage = 'Yürüme dönemi';
    } else {
      ageMessage = 'Konuşma dönemi';
    }

    return '$babyName $timeMessage! $ageMessage $emoji';
  }

  Widget _buildDashboardCard(
    String emoji,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
    VoidCallback? onLongPress,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.textLight,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMoniAssistant() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE6E6FA).withOpacity(0.4), // Soft lila
                  const Color(0xFFF0F8E8).withOpacity(0.4), // Nane yeşili
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE6E6FA).withOpacity(0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE6E6FA).withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🧠', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MiniMoni Asistanı',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bugünlük önerin hazır:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentAiSuggestion,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textDark,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentAiSuggestion =
                            _aiSuggestions[math.Random().nextInt(
                              _aiSuggestions.length,
                            )];
                      });
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Yeni Öneri'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryPink,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgress() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    const Icon(
                      Icons.trending_up,
                      color: AppColors.primaryPink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bu Hafta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '🎯 7 kez gelişim kaydı yaptınız',
                  style: TextStyle(fontSize: 14, color: AppColors.textMedium),
                ),
                const SizedBox(height: 4),
                Text(
                  _baby == null
                      ? '📍 Bebeğinizi ekleyerek kişisel takip başlatın'
                      : '📍 Şu an ${_baby!.ageInMonths}. ay – hareket gelişimi dönemi',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMilkAnalysisSummaryCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/dashboard/feeding-analysis'),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🍼', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Süt Analizi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gün gün süt miktarını ve trendleri görmek için tıkla',
                    style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryPink,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class MiniAnalysisCard extends ConsumerWidget {
  final String title;
  final String icon;
  final Color color;
  final AutoDisposeFutureProvider provider;
  final String unit;
  final bool isPercent;

  const MiniAnalysisCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.provider,
    required this.unit,
    this.isPercent = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(provider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          asyncValue.when(
            data: (value) {
              String display =
                  isPercent
                      ? '${(value as double).toStringAsFixed(1)}%'
                      : '${value ?? 0} $unit';
              return Text(
                display,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink,
                ),
              );
            },
            loading:
                () => const SizedBox(
                  height: 24,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            error: (e, st) => const Text('-', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
