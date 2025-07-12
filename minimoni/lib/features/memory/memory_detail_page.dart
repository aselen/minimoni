import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/models/memory_model.dart';
import 'memory_providers.dart';

class MemoryDetailPage extends ConsumerStatefulWidget {
  final MemoryModel memory;
  const MemoryDetailPage({Key? key, required this.memory}) : super(key: key);

  @override
  ConsumerState<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends ConsumerState<MemoryDetailPage>
    with SingleTickerProviderStateMixin {
  late MemoryModel _memory;
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _tagsController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _memory = widget.memory;
    _isFavorite = _memory.isFavorite;
    _titleController = TextEditingController(text: _memory.title);
    _noteController = TextEditingController(text: _memory.note ?? '');
    _tagsController = TextEditingController(text: _memory.tags.join(', '));
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    final ops = ref.read(memoryOperationsProvider);
    await ops.toggleFavorite(_memory.id);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _deleteMemory() async {
    final ops = ref.read(memoryOperationsProvider);
    final success = await ops.deleteMemory(_memory.id);
    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _saveEdit() async {
    final ops = ref.read(memoryOperationsProvider);
    final updated = _memory.copyWith(
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      tags:
          _tagsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
    );
    final success = await ops.updateMemory(updated);
    if (success && mounted) {
      setState(() {
        _memory = updated;
        _isEditing = false;
      });
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryPink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: AppColors.primaryPink,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryPink),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Düzenle',
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteMemory,
              tooltip: 'Sil',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_memory.hasPhoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_memory.photoPath!),
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _memory.mood.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child:
                        _isEditing
                            ? TextField(
                              controller: _titleController,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Başlık',
                                border: InputBorder.none,
                              ),
                            )
                            : Text(
                              _memory.title,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _memory.formattedDate,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Not',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _isEditing
                  ? TextField(
                    controller: _noteController,
                    maxLines: 5,
                    minLines: 2,
                    style: GoogleFonts.inter(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Not ekle...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  )
                  : Text(
                    _memory.note ?? '-',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textMedium,
                    ),
                  ),
              const SizedBox(height: 20),
              Text(
                'Etiketler',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _isEditing
                  ? TextField(
                    controller: _tagsController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Etiketleri virgül ile ayırın',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  )
                  : Wrap(
                    spacing: 6,
                    children:
                        _memory.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.lightPink.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
              const SizedBox(height: 32),
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Kaydet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryPink,
                          side: const BorderSide(color: AppColors.primaryPink),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'İptal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
  }
}
