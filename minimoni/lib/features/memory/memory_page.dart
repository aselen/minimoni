import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:io';
import 'dart:math' as math;

import '../../core/constants/colors.dart';
import '../../core/models/memory_model.dart';
import '../../shared/widgets/modern_header.dart';
import '../../core/models/baby_model.dart';
import '../../core/services/baby_storage_service.dart';
import '../../core/providers/baby_providers.dart';
import 'memory_providers.dart';
import 'memory_detail_page.dart';

class MemoryPage extends ConsumerStatefulWidget {
  const MemoryPage({super.key});

  @override
  ConsumerState<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends ConsumerState<MemoryPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  int _currentPageIndex = 0;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  MoodType _selectedMood = MoodType.happy;
  XFile? _selectedImage;
  bool _isLoading = false;
  bool _showAddForm = false;
  String _searchQuery = '';
  List<String> _selectedTags = [];

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  late AnimationController _fabScaleController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    _fabScaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _fabScaleController, curve: Curves.easeInOut),
    );

    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    _fabController.dispose();
    _fabScaleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveMemory() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen anıya bir başlık verin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baby = await ref.read(activeBabyProvider.future);
      if (baby == null) {
        throw Exception('Bebek bilgisi bulunamadı');
      }

      final timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final memory = MemoryModel.create(
        babyId: baby.id,
        title: _titleController.text.trim(),
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
        photoPath: _selectedImage?.path,
        mood: _selectedMood,
        timestamp: timestamp,
        tags: _selectedTags,
      );

      final success = await ref.read(memoryServiceProvider).addMemory(memory);

      if (success) {
        // Refresh data
        ref.invalidate(memoriesProvider);
        ref.invalidate(memoryStatsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Özel anınız kaydedildi! 💕'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset form
          _resetForm();
        }
      } else {
        throw Exception('Anı kaydedilemedi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    _titleController.clear();
    _noteController.clear();
    _tagsController.clear();
    _selectedImage = null;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedMood = MoodType.happy;
    _selectedTags.clear();
    setState(() {
      _showAddForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 350;
    final isMedium = width < 400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          ModernHeader(
            title: 'Özel Anlar',
            subtitle: 'Değerli anları kaydet',
            emoji: '📸',
            showBackButton: true,
            isDashboard: false,
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: isSmall ? 16 : 20,
              right: isSmall ? 16 : 20,
              top: 24,
              bottom: 100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_showAddForm) _buildAddMemoryForm(),
                if (_showAddForm) const SizedBox(height: 24),
                _buildMemoryStats(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildMemoryTimeline(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  // Haptic feedback
                  HapticFeedback.lightImpact();

                  // Scale animation
                  await _fabScaleController.forward();
                  await _fabScaleController.reverse();

                  setState(() {
                    _showAddForm = !_showAddForm;
                  });
                },
                backgroundColor: AppColors.primaryPink,
                elevation: 0,
                highlightElevation: 0,
                splashColor: Colors.white.withOpacity(0.3),
                heroTag: "memoryFab",
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Icon(
                    _showAddForm ? Icons.close : Icons.add,
                    key: ValueKey<bool>(_showAddForm),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddMemoryForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni Anı Oluştur',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // Title Input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Anı Başlığı',
              hintText: 'Örn: İlk adımlar',
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLength: 50,
          ),
          const SizedBox(height: 16),

          // Mood Selector
          _buildMoodSelector(),
          const SizedBox(height: 16),

          // Date & Time
          _buildDateTimeSelector(),
          const SizedBox(height: 16),

          // Photo Picker
          _buildPhotoPicker(),
          const SizedBox(height: 16),

          // Note Input
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notlar (İsteğe bağlı)',
              hintText: 'Bu özel anıyla ilgili notlarınızı yazın...',
              prefixIcon: const Icon(Icons.note),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLength: 500,
          ),
          const SizedBox(height: 16),

          // Tags Input
          TextField(
            controller: _tagsController,
            decoration: InputDecoration(
              labelText: 'Etiketler (İsteğe bağlı)',
              hintText: 'Virgülle ayırın: ilkadım, oyun, gelişim',
              prefixIcon: const Icon(Icons.tag),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedTags =
                    value
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
              });
            },
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveMemory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'Anıyı Kaydet',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ruh Hali',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: MoodType.values.length,
            itemBuilder: (context, index) {
              final mood = MoodType.values[index];
              final isSelected = _selectedMood == mood;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primaryPink
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primaryPink
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          mood.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected ? Colors.white : AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotoğraf (İsteğe bağlı)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child:
                _selectedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                    : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 32,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Fotoğraf ekle',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryStats() {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(memoryStatsProvider);

        return statsAsync.when(
          data:
              (stats) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPink.withOpacity(0.1),
                      AppColors.lightPink.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anı İstatistikleri',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard(
                          'Toplam',
                          stats['totalCount'].toString(),
                          '📚',
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Bu Ay',
                          stats['monthCount'].toString(),
                          '🗓️',
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Favoriler',
                          stats['favoriteCount'].toString(),
                          '⭐',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Hata: $e'),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Anıları ara...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildMemoryTimeline() {
    return Consumer(
      builder: (context, ref, child) {
        final memoriesAsync = ref.watch(memoriesProvider);

        return memoriesAsync.when(
          data: (memories) {
            final filteredMemories =
                _searchQuery.isEmpty
                    ? memories
                    : memories
                        .where(
                          (m) =>
                              m.title.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              (m.note?.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ??
                                  false),
                        )
                        .toList();

            if (filteredMemories.isEmpty) {
              return _buildEmptyState();
            }

            return AnimationLimiter(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredMemories.length,
                itemBuilder: (context, index) {
                  final memory = filteredMemories[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: _buildMemoryCard(memory)),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Hata: $e'),
        );
      },
    );
  }

  Widget _buildMemoryCard(MemoryModel memory) {
    return GestureDetector(
      onTap: () async {
        // Navigate to detail page (to be implemented)
        final updated = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MemoryDetailPage(memory: memory),
          ),
        );
        if (updated == true) {
          // Refresh memories if detail page signals an update
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    memory.mood.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        memory.formattedDate,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (memory.hasPhoto)
                  Icon(Icons.photo, color: AppColors.primaryPink, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              memory.shortNote,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
            if (memory.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    memory.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightPink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz anı yok',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk özel anınızı eklemek için + butonuna tıklayın',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
