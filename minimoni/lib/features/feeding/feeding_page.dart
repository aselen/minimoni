import 'package:flutter/material.dart';
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
import '../../shared/widgets/modern_header.dart';
import '../../core/services/feeding_notification_service.dart';

class FeedingPage extends StatefulWidget {
  const FeedingPage({super.key});

  @override
  State<FeedingPage> createState() => _FeedingPageState();
}

class _FeedingPageState extends State<FeedingPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _heroController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  // Animations
  late Animation<double> _heroAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _floatingAnimation;

  // State
  BabyModel? _baby;
  String _selectedFeedingType = 'breast';
  int _selectedAmount = 80;
  String? _selectedSide;
  String _customFoodName = '';
  bool _isFeeding = false;
  DateTime? _feedingStartTime;
  Duration _feedingDuration = Duration.zero;
  List<FeedingModel> _feedingHistory = [];
  DateTime _selectedDateTime = DateTime.now();
  bool _isHistoricalEntry = false;
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Timer for real-time updates
  Timer? _feedingTimer;

  // Track if any new record was saved to update dashboard
  bool _hasNewRecord = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadBaby();
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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOut,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, -0.1),
    ).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
    _floatingController.repeat(reverse: true);
  }

  void _loadBaby() async {
    try {
      final baby = await BabyStorageService.instance.getActiveBaby();
      List<FeedingModel> feedingHistory = [];

      if (baby != null) {
        feedingHistory = await FeedingStorageService.instance
            .getRecentFeedingsForBaby(baby.id, limit: 10);
      }

      setState(() {
        _baby = baby;
        _feedingHistory = feedingHistory;
      });
    } catch (e) {
      print('Error loading baby: $e');
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _feedingTimer?.cancel();
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
              Color(0xFFFFF8F0), // Soft peach
              Color(0xFFFFE4E1), // Misty rose
              Color(0xFFF0F8FF), // Alice blue
              Color(0xFFF5F5DC), // Beige
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              ModernHeader(
                title: 'Beslenme Takibi',
                emoji: '🍼',
                showBackButton: true,
                onBackPressed: () => context.pop(_hasNewRecord),
                isDashboard: false,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDateTimeSelector(),
                    const SizedBox(height: 20),
                    _buildFeedingTypeSelector(),
                    const SizedBox(height: 20),
                    _buildFeedingDetails(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 30),
                    _buildRecentHistory(),
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

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.95),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => context.pop(_hasNewRecord),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textDark,
                  size: 14,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE4E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.textDark,
                size: 14,
              ),
            ),
            const Text(
              'Beslenme',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
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
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Şimdi',
                      style: TextStyle(
                        color:
                            !_isHistoricalEntry
                                ? AppColors.textDark
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
              onTap: () {
                setState(() {
                  _isHistoricalEntry = true;
                });
              },
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
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Eskiye Dönük',
                      style: TextStyle(
                        color:
                            _isHistoricalEntry
                                ? AppColors.textDark
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
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryPink,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.primaryPink,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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

  Widget _buildFeedingTypeSelector() {
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
                        Icons.category,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Beslenme Türü',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeedingTypeCard(
                        type: 'breast',
                        title: 'Anne\nSütü',
                        icon: Icons.pregnant_woman,
                        emoji: '🤱',
                        color: const Color(0xFFFFE4E1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildFeedingTypeCard(
                        type: 'formula',
                        title: 'Biberon',
                        icon: Icons.baby_changing_station,
                        emoji: '🍼',
                        color: const Color(0xFFE6E6FA),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildFeedingTypeCard(
                        type: 'solid',
                        title: 'Katı Besin',
                        icon: Icons.restaurant,
                        emoji: '🍎',
                        color: const Color(0xFFF0F8E8),
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

  Widget _buildFeedingTypeCard({
    required String type,
    required String title,
    required IconData icon,
    required String emoji,
    required Color color,
  }) {
    final isSelected = _selectedFeedingType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeedingType = type;
          if (type != 'breast') {
            _selectedSide = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize:
                    type == 'breast'
                        ? (isSelected ? 20 : 18)
                        : (isSelected ? 24 : 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize:
                    type == 'breast'
                        ? (isSelected ? 10 : 9)
                        : (isSelected ? 11 : 10),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingDetails() {
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
                        Icons.tune,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Detaylar',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedFeedingType == 'breast') ...[
                  _buildBreastSideSelector(),
                  const SizedBox(height: 16),
                  _buildTimerSection(),
                ] else if (_selectedFeedingType == 'formula') ...[
                  _buildAmountSelector(),
                ] else if (_selectedFeedingType == 'solid') ...[
                  _buildAmountSelector(),
                  const SizedBox(height: 16),
                  _buildCustomFoodInput(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreastSideSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hangi Göğüs',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSideCard('left', 'Sol', '👈')),
            const SizedBox(width: 12),
            Expanded(child: _buildSideCard('right', 'Sağ', '👉')),
            const SizedBox(width: 12),
            Expanded(child: _buildSideCard('both', 'İkisi', '🤱')),
          ],
        ),
      ],
    );
  }

  Widget _buildSideCard(String side, String title, String emoji) {
    final isSelected = _selectedSide == side;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSide = side;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE4E1) : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFE4E1) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: isSelected ? 24 : 20)),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: AppColors.primaryPink, size: 24),
              const SizedBox(width: 8),
              Text(
                _isFeeding
                    ? 'Süre: ${_formatDuration(_feedingDuration)}'
                    : 'Zamanlayıcı',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isHistoricalEntry) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isFeeding) ...[
                  ElevatedButton.icon(
                    onPressed: _startFeeding,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ] else ...[
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: ElevatedButton.icon(
                          onPressed: _stopFeeding,
                          icon: const Icon(Icons.stop),
                          label: const Text('Durdur'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedFeedingType == 'formula' ? 'Miktar (ml)' : 'Miktar (gr/ml)',
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedAmount > 10) _selectedAmount -= 10;
                      });
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      '$_selectedAmount',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedAmount < 500) _selectedAmount += 10;
                      });
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: _selectedAmount.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                activeColor: AppColors.primaryPink,
                inactiveColor: const Color(0xFFE0E0E0),
                onChanged: (value) {
                  setState(() {
                    _selectedAmount = value.round();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomFoodInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Besin Adı',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          onChanged: (value) {
            setState(() {
              _customFoodName = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Örn: Pirinç lapası, muz, elma vs.',
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryPink),
            ),
            prefixIcon: const Icon(
              Icons.restaurant,
              color: AppColors.primaryPink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    // Anne sütü seçili iken kaydet butonunu gizle (zamanlayıcı kullanılır)
    if (_selectedFeedingType == 'breast') {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _canSave() ? _saveFeeding : null,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Kaydet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentHistory() {
    if (_feedingHistory.isEmpty) {
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
            'Henüz beslenme kaydı yok',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
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
                'Son Beslenme Kayıtları',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_feedingHistory
              .take(5)
              .map((feeding) => _buildHistoryItem(feeding))),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(FeedingModel feeding) {
    final typeEmoji = _getTypeEmoji(feeding.type);
    final timeAgo = _getTimeAgo(feeding.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(feeding.type),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(typeEmoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feeding.typeDisplayName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feeding.displayAmount,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTypeEmoji(String type) {
    switch (type) {
      case 'breast':
        return '🤱';
      case 'formula':
        return '🍼';
      case 'solid':
        return '🍎';
      default:
        return '🍼';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'breast':
        return const Color(0xFFFFE4E1);
      case 'formula':
        return const Color(0xFFE6E6FA);
      case 'solid':
        return const Color(0xFFF0F8E8);
      default:
        return const Color(0xFFF8F8F8);
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}sa önce';
    } else {
      return '${difference.inDays}g önce';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  bool _canSave() {
    if (_baby == null) return false;
    if (_selectedFeedingType == 'breast' && _selectedSide == null) return false;
    if (_selectedFeedingType == 'solid' && _customFoodName.trim().isEmpty)
      return false;
    return true;
  }

  void _startFeeding() {
    if (!_isFeeding && _selectedFeedingType == 'breast') {
      if (_selectedSide == null) {
        _showError('Lütfen hangi göğüs olduğunu seçin 🤱');
        return;
      }
      setState(() {
        _isFeeding = true;
        _feedingStartTime = DateTime.now();
        _feedingDuration = Duration.zero;
      });
      _pulseController.repeat(reverse: true);

      // Start the timer for real-time updates
      _feedingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isFeeding && _feedingStartTime != null) {
          setState(() {
            _feedingDuration = DateTime.now().difference(_feedingStartTime!);
          });
        }
      });
    }
  }

  void _stopFeeding() async {
    if (_isFeeding && _baby != null) {
      // Stop the timer
      _feedingTimer?.cancel();
      _feedingTimer = null;

      final endTime = DateTime.now();
      if (_feedingStartTime != null) {
        _feedingDuration = endTime.difference(_feedingStartTime!);
      }

      setState(() {
        _isFeeding = false;
      });
      _pulseController.stop();

      await _saveFeeding();
    }
  }

  Future<void> _saveFeeding() async {
    if (_baby == null) return;

    final DateTime finalDateTime =
        _isHistoricalEntry ? _selectedDateTime : DateTime.now();

    final feeding = FeedingModel(
      id: FeedingModel.generateId(),
      babyId: _baby!.id,
      type: _selectedFeedingType,
      amount: _selectedFeedingType != 'breast' ? _selectedAmount : null,
      duration: _selectedFeedingType == 'breast' ? _feedingDuration : null,
      timestamp: finalDateTime,
      side: _selectedFeedingType == 'breast' ? _selectedSide : null,
      note: _selectedFeedingType == 'solid' ? _customFoodName.trim() : null,
    );

    final success = await FeedingStorageService.instance.addFeeding(feeding);
    if (success) {
      _hasNewRecord = true; // Yeni kayıt eklendi
      _loadBaby();
      _checkForNewBadges();

      // Bildirim analizi yap
      await _analyzeFeedingForNotifications();

      _showSuccessDialog();
      _resetForm();
    }
  }

  void _checkForNewBadges() async {
    if (_baby != null) {
      try {
        await BadgeManagerService.instance.checkAndAwardBadges(_baby!.id);
      } catch (e) {
        print('Error checking badges: $e');
      }
    }
  }

  Future<void> _analyzeFeedingForNotifications() async {
    if (_baby != null) {
      try {
        await FeedingNotificationService.instance
            .analyzeFeedingAndCreateNotifications(_baby!.id);
      } catch (e) {
        print('Error analyzing feeding for notifications: $e');
      }
    }
  }

  void _resetForm() {
    // Stop and clear the timer
    _feedingTimer?.cancel();
    _feedingTimer = null;

    setState(() {
      _selectedFeedingType = 'breast';
      _selectedAmount = 80;
      _selectedSide = null;
      _customFoodName = '';
      _isFeeding = false;
      _feedingStartTime = null;
      _feedingDuration = Duration.zero;
      _selectedDateTime = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _isHistoricalEntry = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Başarılı! 🎉'),
            content: const Text('Beslenme kaydı başarıyla eklendi.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Sadece dialog'u kapat
                  // Feeding sayfasında kal, ana sayfaya yönlendirme
                },
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }
}
