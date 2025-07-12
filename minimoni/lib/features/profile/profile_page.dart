import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/models/baby_model.dart';
import '../../core/providers/baby_providers.dart';
import '../../core/providers/theme_provider.dart';
import '../../shared/widgets/modern_header.dart';
import '../../shared/widgets/baby_selector.dart';
import 'add_baby_page.dart';
import 'theme_settings_page.dart';
import 'notification_settings_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          ModernHeader(
            title: 'Profil',
            subtitle: 'Bebek bilgileri ve ayarlar',
            emoji: '👤',
            showBackButton: true,
            isDashboard: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                BabySelector(
                  onAddBaby: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddBabyPage(),
                      ),
                    );
                    if (result == true) {
                      // Refresh data
                      ref.invalidate(allBabiesProvider);
                      ref.invalidate(activeBabyProvider);
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildBabyInfoSection(ref),
                const SizedBox(height: 24),
                _buildSettingsSection(context),
                const SizedBox(height: 24),
                _buildAppInfoSection(context),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfoSection(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final activeBabyAsync = ref.watch(activeBabyProvider);

        return activeBabyAsync.when(
          data: (baby) {
            if (baby == null) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.all(20),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          baby.genderEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              baby.name,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              baby.ageString,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                            ),
                            if (baby.parentName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Ebeveyn: ${baby.parentName}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (baby == null) return;
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder: (context) => EditBabySheet(baby: baby),
                          );
                          if (result == true) {
                            ref.invalidate(activeBabyProvider);
                            ref.invalidate(allBabiesProvider);
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.primaryPink,
                        ),
                        tooltip: 'Düzenle',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Doğum Tarihi',
                          '${baby.birthDate.day}/${baby.birthDate.month}/${baby.birthDate.year}',
                          Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Cinsiyet',
                          baby.gender == 'erkek' ? 'Erkek' : 'Kız',
                          Icons.person,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Hata: $e'),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryPink, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: const Icon(
                  Icons.settings,
                  color: AppColors.primaryPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ayarlar',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'Bildirimler',
            'Bildirim ayarlarını yönet',
            Icons.notifications,
            () {
              print('Bildirim ayarları butonuna tıklandı'); // Debug print
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
          _buildSettingItem('Tema', 'Açık/Koyu tema seçimi', Icons.palette, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ThemeSettingsPage(),
              ),
            );
          }),
          _buildSettingItem('Dil', 'Türkçe/İngilizce', Icons.language, () {
            // TODO: Language settings
          }),
          const SizedBox(height: 16),
          Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              'Tüm Verileri Sıfırla',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              'Tüm bebekler ve kayıtlar silinir',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.red.withOpacity(0.7),
              ),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Tüm Verileri Sıfırla'),
                      content: const Text(
                        'Tüm bebekler ve kayıtlar silinecek. Emin misiniz? Bu işlem geri alınamaz.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Evet, Sıfırla'),
                        ),
                      ],
                    ),
              );
              if (confirmed == true) {
                final service = ref.read(babyStorageServiceProvider);
                final success = await service.clearAllData();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tüm veriler silindi!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // TODO: Onboarding veya giriş ekranına yönlendir
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veriler silinemedi!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryPink, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: const Icon(
                  Icons.info,
                  color: AppColors.primaryPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Uygulama Bilgileri',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem('Versiyon', '1.0.0'),
          _buildInfoItem('Geliştirici', 'MiniMoni Team'),
          _buildInfoItem('Lisans', 'MIT License'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMedium),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class EditBabySheet extends ConsumerStatefulWidget {
  final BabyModel baby;
  const EditBabySheet({Key? key, required this.baby}) : super(key: key);

  @override
  ConsumerState<EditBabySheet> createState() => _EditBabySheetState();
}

class _EditBabySheetState extends ConsumerState<EditBabySheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _parentNameController;
  late String _selectedGender;
  late DateTime _selectedBirthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.baby.name);
    _parentNameController = TextEditingController(
      text: widget.baby.parentName ?? '',
    );
    _selectedGender = widget.baby.gender;
    _selectedBirthDate = widget.baby.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final updated = widget.baby.copyWith(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        birthDate: _selectedBirthDate,
        parentName: _parentNameController.text.trim(),
      );
      final operations = ref.read(babyOperationsProvider);
      final success = await operations.updateBaby(updated);
      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Bebek güncellenemedi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bebek Bilgilerini Düzenle',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bebek Adı *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Bebek adı',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryPink),
                  ),
                  prefixIcon: const Icon(
                    Icons.baby_changing_station,
                    color: AppColors.primaryPink,
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Bebek adı gerekli'
                            : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Cinsiyet *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildGenderCard('erkek', '👦', 'Erkek')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGenderCard('kız', '👧', 'Kız')),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Doğum Tarihi *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryPink,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedBirthDate.day}/${_selectedBirthDate.month}/${_selectedBirthDate.year}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primaryPink,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ebeveyn Adı *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _parentNameController,
                decoration: InputDecoration(
                  hintText: 'Anne/baba adı',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryPink),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppColors.primaryPink,
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Ebeveyn adı gerekli'
                            : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Kaydet',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String gender, String emoji, String label) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryPink : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
