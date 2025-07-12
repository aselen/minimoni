import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/constants/colors.dart';
import '../../core/models/baby_model.dart';
import '../../core/services/baby_storage_service.dart';
import '../../core/models/sleep_model.dart';
import '../../core/services/sleep_storage_service.dart';
import '../../shared/widgets/modern_header.dart';
import 'sleep_notification_page.dart';
import 'dart:math' as math;
import '../../core/services/sleep_notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sleep_music_page.dart';

class SleepPage extends ConsumerStatefulWidget {
  const SleepPage({super.key});

  @override
  ConsumerState<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends ConsumerState<SleepPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _heroController;
  late AnimationController _cardController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _heroAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _pulseAnimation;

  // State
  BabyModel? _baby;
  bool _isLoading = true;
  List<SleepModel> _todaySleepRecords = [];
  SleepModel? _activeSleep;
  Map<String, dynamic> _sleepStats = {};

  // Timer for real-time updates
  Timer? _sleepTimer;
  Duration _currentSleepDuration = Duration.zero;

  // Track if any new sleep record was created
  bool _hasNewRecord = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    _startAnimations();
  }

  void _initAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutBack,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  void _loadData() async {
    final baby = await BabyStorageService.instance.getActiveBaby();
    List<SleepModel> todaySleepRecords = [];
    SleepModel? activeSleep;
    Map<String, dynamic> sleepStats = {};

    if (baby != null) {
      todaySleepRecords = await SleepStorageService.instance
          .getTodaySleepRecords(baby.id);
      activeSleep = await SleepStorageService.instance.getActiveSleepRecord(
        baby.id,
      );
      sleepStats = await SleepStorageService.instance.getSleepStats(baby.id);
    }

    if (mounted) {
      setState(() {
        _baby = baby;
        _todaySleepRecords = todaySleepRecords;
        _activeSleep = activeSleep;
        _sleepStats = sleepStats;
        _isLoading = false;
      });

      // Start timer if there's active sleep
      if (activeSleep != null) {
        _startSleepTimer();
      } else {
        _sleepTimer?.cancel();
        _sleepTimer = null;
      }
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    _sleepTimer?.cancel();
    super.dispose();
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
          child:
              _isLoading
                  ? _buildLoadingState()
                  : CustomScrollView(
                    slivers: [
                      ModernHeader(
                        title: 'Uyku Takibi',
                        emoji: '😴',
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
                              _buildSleepControls(),
                              const SizedBox(height: 20),
                              _buildTodayStats(),
                              const SizedBox(height: 20),
                              _buildRecentSleepRecords(),
                              const SizedBox(height: 20),
                              _buildWeeklyStats(),
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
            'Uyku verileri yükleniyor...',
            style: TextStyle(color: AppColors.textMedium, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(_hasNewRecord),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 20,
          ),
        ),
      ),
      flexibleSpace: AnimatedBuilder(
        animation: _heroAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _heroAnimation.value,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('😴', style: TextStyle(fontSize: 32)),
                  SizedBox(height: 8),
                  Text(
                    'Uyku Takibi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      centerTitle: true,
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
                        Color(0xFFE6E6FA), // Lavender
                        Color(0xFFE6F7FF), // Light blue
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
                        '${_baby!.name}\'nin Uyku Takibi',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activeSleep != null
                            ? 'Şu anda uyuyor 😴'
                            : 'Uyanık durumda 😊',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                      ),
                      if (_activeSleep != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Uyku süresi: ${_getActiveSleepDuration()}',
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

  Widget _buildSleepControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Uyku Kontrolleri',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  icon: _activeSleep != null ? Icons.stop : Icons.play_arrow,
                  title:
                      _activeSleep != null ? 'Uykuyu Durdur' : 'Uykuyu Başlat',
                  subtitle:
                      _activeSleep != null
                          ? 'Uyku kaydını sonlandır'
                          : 'Yeni uyku kaydı başlat',
                  color:
                      _activeSleep != null ? Colors.red : AppColors.primaryPink,
                  onTap:
                      () =>
                          _activeSleep != null
                              ? _stopSleep()
                              : _showSleepTypeDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlButton(
                  icon: Icons.music_note,
                  title: 'Uyku Müziği',
                  subtitle: 'Sakinleştirici sesler',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SleepMusicPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopSleepCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE6E6FA).withOpacity(0.4), // Soft lavender
                  const Color(0xFFE6F7FF).withOpacity(0.4), // Light blue
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE6E6FA).withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Text('😴', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  '${_activeSleep!.type.displayName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Başlangıç: ${_formatTime(_activeSleep!.startTime)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Süre: ${_getActiveSleepDuration()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPink,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _stopSleep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Uykuyu Sonlandır',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartSleepOptions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children:
          SleepType.values.map((type) {
            return _buildSleepTypeCard(type);
          }).toList(),
    );
  }

  Widget _buildSleepTypeCard(SleepType type) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _startSleep(type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7FF).withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE6F7FF).withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE6F7FF).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(type.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                type.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
                const Row(
                  children: [
                    Icon(Icons.today, color: AppColors.primaryPink, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Bugünkü Uyku',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Toplam Uyku',
                        '${_sleepStats['todayTotalHours'] ?? '0.0'}s',
                        '🕐',
                        const Color(0xFFE6F3FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Uyku Sayısı',
                        '${_sleepStats['todayCount'] ?? 0}',
                        '💤',
                        const Color(0xFFF0F8E8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSleepRecords() {
    if (_todaySleepRecords.isEmpty) {
      return const SizedBox.shrink();
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
                const Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primaryPink, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Bugünkü Uyku Kayıtları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _todaySleepRecords.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sleep = _todaySleepRecords[index];
                    return _buildSleepRecordCard(sleep);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepRecordCard(SleepModel sleep) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Text(sleep.type.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sleep.type.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatTime(sleep.startTime)} - ${sleep.endTime != null ? _formatTime(sleep.endTime!) : 'Devam ediyor'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Text(
            sleep.durationString,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
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
                const Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppColors.primaryPink,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bu Hafta İstatistikleri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Günlük Ortalama',
                        '${_sleepStats['weeklyAverageHours'] ?? '0.0'}s',
                        '📊',
                        const Color(0xFFFFE4E1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'En Uzun Uyku',
                        '${_sleepStats['longestSleepHours'] ?? '0.0'}s',
                        '🏆',
                        const Color(0xFFFFF0F5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoBabyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👶', style: TextStyle(fontSize: 64)),
          SizedBox(height: 24),
          Text(
            'Uyku takibi için önce bebeğinizi ekleyin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Ana sayfaya giderek bebeğinizin bilgilerini ekleyebilirsiniz',
            style: TextStyle(fontSize: 14, color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _startSleepTimer() {
    _sleepTimer?.cancel();
    if (_activeSleep != null) {
      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_activeSleep != null && mounted) {
          setState(() {
            _currentSleepDuration = DateTime.now().difference(
              _activeSleep!.startTime,
            );
          });
        }
      });
    }
  }

  void _showSleepTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Uyku Tipi Seç'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('Gece Uykusu'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startSleep(SleepType.nightSleep);
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('Gündüz Uykusu'),
                onTap: () {
                  Navigator.of(context).pop();
                  _startSleep(SleepType.dayNap);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startSleep(SleepType type) async {
    if (_baby == null) return;

    final sleep = SleepModel.create(
      babyId: _baby!.id,
      startTime: DateTime.now(),
      type: type,
    );

    final success = await SleepStorageService.instance.addSleepRecord(sleep);
    if (success) {
      _hasNewRecord = true; // Yeni kayıt eklendi
      _loadData(); // Verileri yenile (timer da başlatılacak)

      // Akıllı uyku analizi yap
      await SleepNotificationService.instance
          .analyzeSleepAndCreateNotifications(_baby!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type.displayName} başlatıldı'),
          backgroundColor: AppColors.primaryPink,
        ),
      );
    }
  }

  void _stopSleep() async {
    if (_activeSleep == null) return;

    // Stop the timer first
    _sleepTimer?.cancel();
    _sleepTimer = null;

    final success = await SleepStorageService.instance.endSleepRecord(
      _activeSleep!.id,
      DateTime.now(),
    );

    if (success) {
      _hasNewRecord = true; // Uyku sonlandırıldı, dashboard'ı güncelle
      _loadData(); // Verileri yenile

      // Akıllı uyku analizi yap
      await SleepNotificationService.instance
          .analyzeSleepAndCreateNotifications(_baby!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uyku sonlandırıldı'),
          backgroundColor: AppColors.primaryPink,
        ),
      );
    }
  }

  String _getActiveSleepDuration() {
    if (_activeSleep == null) return '';

    // Use the real-time duration from timer
    final duration =
        _currentSleepDuration.inSeconds > 0
            ? _currentSleepDuration
            : DateTime.now().difference(_activeSleep!.startTime);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    } else if (minutes > 0) {
      return '${minutes}dk ${seconds}sn';
    } else {
      return '${seconds}sn';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
