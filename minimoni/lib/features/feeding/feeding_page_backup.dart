import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../core/constants/colors.dart';
import '../../core/models/baby_model.dart';
import '../../core/services/baby_storage_service.dart';
import '../../core/models/feeding_model.dart';
import '../../core/services/feeding_storage_service.dart';

class FeedingPage extends StatefulWidget {
  const FeedingPage({super.key});

  @override
  State<FeedingPage> createState() => _FeedingPageState();
}

class _FeedingPageState extends State<FeedingPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _feedingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late List<Animation<double>> _cardAnimations;
  late List<Animation<Offset>> _slideAnimations;

  BabyModel? _baby;
  bool _isLoading = true;
  String _selectedFeedingType = 'breast';
  int _selectedAmount = 80;
  bool _isFeeding = false;
  DateTime? _feedingStartTime;
  Duration _feedingDuration = Duration.zero;
  List<FeedingModel> _feedingHistory = [];
  String? _selectedSide; // For breast feeding
  String _customFoodName = ''; // For solid food custom name

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadBaby();
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _feedingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Card animations
    _cardAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (0.3 + (index * 0.05)).clamp(0.0, 1.0),
            (0.7 + (index * 0.1)).clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    // Slide animations
    _slideAnimations = List.generate(3, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (0.4 + (index * 0.05)).clamp(0.0, 1.0),
            (0.8 + (index * 0.1)).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _pulseController.repeat(reverse: true);
    _controller.forward();
  }

  void _loadBaby() async {
    final baby = await BabyStorageService.instance.getActiveBaby();
    List<FeedingModel> feedingHistory = [];

    if (baby != null) {
      feedingHistory = await FeedingStorageService.instance
          .getRecentFeedingsForBaby(baby.id, limit: 10);
    }

    setState(() {
      _baby = baby;
      _feedingHistory = feedingHistory;
      _isLoading = false;
    });
  }

  void _startFeeding() {
    if (!_isFeeding) {
      setState(() {
        _isFeeding = true;
        _feedingStartTime = DateTime.now();
      });
      _feedingController.repeat();
    }
  }

  void _saveDirectFeeding() async {
    if (_baby == null) return;

    // Validate solid food name
    if (_selectedFeedingType == 'solid' && _customFoodName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen besin adını girin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create feeding record without timer
    final feeding = FeedingModel(
      id: FeedingModel.generateId(),
      babyId: _baby!.id,
      type: _selectedFeedingType,
      amount: _selectedAmount,
      duration: null,
      timestamp: DateTime.now(),
      side: null,
      note: _selectedFeedingType == 'solid' ? _customFoodName.trim() : null,
    );

    // Save to database
    final success = await FeedingStorageService.instance.addFeeding(feeding);
    if (success) {
      // Reload feeding history
      _loadBaby();
      _showFeedingComplete();
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beslenme kaydedilemedi. Tekrar deneyin.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _stopFeeding() async {
    if (_isFeeding && _baby != null) {
      final endTime = DateTime.now();
      if (_feedingStartTime != null) {
        _feedingDuration = endTime.difference(_feedingStartTime!);
      }

      setState(() {
        _isFeeding = false;
      });
      _feedingController.stop();
      _feedingController.reset();

      // Create feeding record
      final feeding = FeedingModel(
        id: FeedingModel.generateId(),
        babyId: _baby!.id,
        type: _selectedFeedingType,
        amount: _selectedFeedingType != 'breast' ? _selectedAmount : null,
        duration: _selectedFeedingType == 'breast' ? _feedingDuration : null,
        timestamp: endTime,
        side: _selectedFeedingType == 'breast' ? _selectedSide : null,
      );

      // Save to database
      final success = await FeedingStorageService.instance.addFeeding(feeding);
      if (success) {
        // Reload feeding history
        _loadBaby();
        _showFeedingComplete();
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Beslenme kaydedilemedi. Tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFeedingComplete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.pastelGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Beslenme Tamamlandi!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedFeedingType == 'breast') ...[
                  Text('Sure: ${_feedingDuration.inMinutes} dakika'),
                  Text('Tip: ${_getFeedingTypeName(_selectedFeedingType)}'),
                  if (_selectedSide != null)
                    Text('Gogus: ${_getSideDisplayName(_selectedSide!)}'),
                ] else ...[
                  Text('Tip: ${_getFeedingTypeName(_selectedFeedingType)}'),
                  Text('Miktar: ${_selectedAmount}ml'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }

  String _getFeedingTypeName(String type) {
    switch (type) {
      case 'breast':
        return 'Anne Sutu';
      case 'formula':
        return 'Biberon';
      case 'solid':
        return 'Kati Besin';
      default:
        return type;
    }
  }

  String _getSideDisplayName(String side) {
    switch (side) {
      case 'left':
        return 'Sol gogus';
      case 'right':
        return 'Sag gogus';
      case 'both':
        return 'Her iki gogus';
      default:
        return side;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _feedingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientStart,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientStart,
              AppColors.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFeedingTypeSelector(),
                    const SizedBox(height: 24),
                    _buildAmountSelector(),
                    const SizedBox(height: 24),
                    _buildFeedingButton(),
                    const SizedBox(height: 32),
                    _buildFeedingHistory(),
                    const SizedBox(height: 24),
                    _buildFeedingTips(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.pastelGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: AppColors.pastelGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Beslenme',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildFeedingTypeSelector() {
    return AnimatedBuilder(
      animation: _cardAnimations[0],
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimations[0].value,
          child: SlideTransition(
            position: _slideAnimations[0],
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beslenme Tipi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildTypeButton('breast', Icons.child_care, 'Anne Sutu'),
                      const SizedBox(width: 12),
                      _buildTypeButton('formula', Icons.local_drink, 'Biberon'),
                      const SizedBox(width: 12),
                      _buildTypeButton('solid', Icons.restaurant, 'Kati Besin'),
                    ],
                  ),
                  if (_selectedFeedingType == 'breast') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Hangi Gogus?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSideButton('left', 'Sol'),
                        const SizedBox(width: 12),
                        _buildSideButton('right', 'Sag'),
                        const SizedBox(width: 12),
                        _buildSideButton('both', 'Her İkisi'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeButton(String type, IconData icon, String label) {
    final isSelected = _selectedFeedingType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFeedingType = type;
            // Reset form data when type changes
            if (type != 'breast') {
              _selectedSide = null;
            }
            if (type != 'solid') {
              _customFoodName = '';
            }
            // Reset feeding state
            if (_isFeeding) {
              _feedingController.stop();
              _feedingController.reset();
              _isFeeding = false;
              _feedingStartTime = null;
              _feedingDuration = Duration.zero;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primaryPink.withOpacity(0.15)
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryPink : AppColors.mediumGray,
              width: 2,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primaryPink.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: AppColors.lightGray.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primaryPink.withOpacity(0.3)
                          : AppColors.offWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? AppColors.primaryPink : AppColors.textMedium,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primaryPink : AppColors.textMedium,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSelector() {
    if (_selectedFeedingType == 'breast') {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _cardAnimations[1],
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimations[1].value,
          child: SlideTransition(
            position: _slideAnimations[1],
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pastelBlue.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Katı besin için custom besin adı girişi
                  if (_selectedFeedingType == 'solid') ...[
                    Text(
                      'Besin Adı',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _customFoodName = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Ör: Elma püresi, pirinç lapası',
                        hintStyle: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.offWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    _selectedFeedingType == 'solid' ? 'Miktar' : 'Miktar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedAmount = math.max(
                              10,
                              _selectedAmount - 10,
                            );
                          });
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.pastelBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: AppColors.pastelBlue,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$_selectedAmount ml',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedAmount = math.min(
                              300,
                              _selectedAmount + 10,
                            );
                          });
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.pastelBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.pastelBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedingButton() {
    // Anne sütü için zamanlayıcı buton, diğerleri için kaydet butonu
    if (_selectedFeedingType == 'breast') {
      return _buildTimerButton();
    } else {
      return _buildSaveButton();
    }
  }

  Widget _buildTimerButton() {
    return AnimatedBuilder(
      animation: _cardAnimations[2],
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimations[2].value,
          child: SlideTransition(
            position: _slideAnimations[2],
            child: AnimatedBuilder(
              animation: _isFeeding ? _pulseAnimation : _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isFeeding ? _pulseAnimation.value : 1.0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_selectedFeedingType == 'breast' &&
                            _selectedSide == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lütfen hangi göğüs olduğunu seçin',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        if (_isFeeding) {
                          _stopFeeding();
                        } else {
                          _startFeeding();
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                _isFeeding
                                    ? [
                                      AppColors.error,
                                      AppColors.error.withOpacity(0.8),
                                    ]
                                    : [
                                      AppColors.pastelGreen,
                                      AppColors.pastelGreen.withOpacity(0.8),
                                    ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_isFeeding
                                      ? AppColors.error
                                      : AppColors.pastelGreen)
                                  .withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isFeeding
                                  ? Icons.stop_circle
                                  : Icons.play_circle,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isFeeding
                                  ? 'Beslenmeyi Durdur'
                                  : 'Beslenmeyi Başlat',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _cardAnimations[2],
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimations[2].value,
          child: SlideTransition(
            position: _slideAnimations[2],
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _saveDirectFeeding,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryPink,
                        AppColors.primaryPink.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _selectedFeedingType == 'solid'
                            ? 'Besin Kaydını Yap'
                            : 'Beslenmeyi Kaydet',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedingHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Beslenmeler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _feedingHistory.isEmpty
            ? Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: AppColors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henuz beslenme kaydı yok',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ilk beslenme kaydınızı yapmak icin yukardaki butonu kullanın',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _feedingHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final feeding = _feedingHistory[index];
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = (0.6 + (index * 0.05)).clamp(0.0, 0.8);
                    final animationValue = (_controller.value - delay).clamp(
                      0.0,
                      1.0,
                    );
                    final transformedValue = Curves.easeOutBack.transform(
                      animationValue,
                    );

                    return Transform.translate(
                      offset: Offset(
                        0,
                        30 * (1 - transformedValue.clamp(0.0, 1.0)),
                      ),
                      child: Opacity(
                        opacity: transformedValue.clamp(0.0, 1.0),
                        child: _buildHistoryItem(feeding),
                      ),
                    );
                  },
                );
              },
            ),
      ],
    );
  }

  Widget _buildHistoryItem(FeedingModel feeding) {
    Color typeColor;
    IconData typeIcon;

    switch (feeding.type) {
      case 'breast':
        typeColor = AppColors.pastelGreen;
        typeIcon = Icons.child_care;
        break;
      case 'formula':
        typeColor = AppColors.pastelBlue;
        typeIcon = Icons.local_drink;
        break;
      case 'solid':
        typeColor = AppColors.pastelYellow;
        typeIcon = Icons.restaurant;
        break;
      default:
        typeColor = AppColors.primaryPink;
        typeIcon = Icons.restaurant_menu;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feeding.timeAgo,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feeding.displayNote,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            feeding.displayAmount,
            style: TextStyle(color: typeColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton(String side, String label) {
    final isSelected = _selectedSide == side;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSide = side;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.pastelGreen.withOpacity(0.15)
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.pastelGreen : AppColors.mediumGray,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.pastelGreen : AppColors.textMedium,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedingTips() {
    if (_baby == null) return const SizedBox.shrink();

    String tip = 'Bebeginizin beslenme duzenini takip etmeyi unutmayin.';

    final ageInMonths = _baby!.ageInMonths;
    if (ageInMonths <= 6) {
      tip = 'Ilk 6 ay sadece anne sutu veya formula yeterli. Sik sik besleyin.';
    } else if (ageInMonths <= 12) {
      tip =
          'Artik kati besinlere gecis zamani! Tek seferde bir yeni besin deneyin.';
    } else {
      tip =
          'Cesitli besinler deneyin ve bebeginizin tercihlerini kesfetmeye devam edin.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb,
              color: AppColors.accentOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(color: AppColors.white, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
