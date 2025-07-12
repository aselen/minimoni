import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/logo_widget.dart';
import '../../app/router.dart';
import '../../core/constants/colors.dart';

/// Onboarding Page
/// Multi-step introduction and setup flow
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form data
  String _babyName = '';
  DateTime? _babyBirthDate;
  String _babyGender = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Onboarding tamamlandı, ana sayfaya git
      context.go(AppRoutes.dashboard);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              _buildProgressBar(),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildFeaturesPage(),
                    _buildBabyInfoPage(),
                    _buildReadyPage(),
                  ],
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color:
                    index <= _currentStep
                        ? AppColors.primaryPink
                        : AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LogoWidget(size: 120, showText: false),
          const SizedBox(height: 24),
          Text(
            'Hoş Geldiniz!',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'MiniMoni, bebeğinizin gelişim sürecini takip etmenize yardımcı olan akıllı asistanınız.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textMedium,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: AppColors.primaryPink,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bebeğinizin büyüme yolculuğuna birlikte başlayalım!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage() {
    final features = [
      {
        'icon': Icons.restaurant_menu,
        'title': 'Beslenme Takibi',
        'description': 'Anne sütü, mama ve katı gıda kayıtları',
      },
      {
        'icon': Icons.bedtime,
        'title': 'Uyku Analizi',
        'description': 'Uyku saatleri ve kalite takibi',
      },
      {
        'icon': Icons.child_care,
        'title': 'Gelişim Takibi',
        'description': 'Boy, kilo ve gelişim kilometre taşları',
      },
      {
        'icon': Icons.psychology,
        'title': 'AI Asistan',
        'description': 'Kişiselleştirilmiş öneriler ve ipuçları',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Özellikler',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'MiniMoni ile bebeğinizin gelişimini kolayca takip edin',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: AppColors.primaryPink,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature['title'] as String,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feature['description'] as String,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Bebeğiniz Hakkında',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Size daha iyi hizmet verebilmek için bebeğiniz hakkında birkaç bilgi alalım',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Baby Name Input
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Bebeğinizin Adı',
                hintText: 'Örn: Zeynep',
                prefixIcon: Icon(Icons.child_care),
              ),
              onChanged: (value) {
                setState(() {
                  _babyName = value;
                });
              },
            ),
          ),

          // Gender Selection
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cinsiyet', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _babyGender = 'girl'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _babyGender == 'girl'
                                    ? AppColors.primaryPink.withOpacity(0.1)
                                    : AppColors.lightGray,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _babyGender == 'girl'
                                      ? AppColors.primaryPink
                                      : AppColors.mediumGray,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('👧', style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                'Kız',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _babyGender = 'boy'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _babyGender == 'boy'
                                    ? AppColors.primaryPink.withOpacity(0.1)
                                    : AppColors.lightGray,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _babyGender == 'boy'
                                      ? AppColors.primaryPink
                                      : AppColors.mediumGray,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('👶', style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                'Erkek',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Birth Date
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(
                    const Duration(days: 30),
                  ),
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 1095),
                  ), // 3 years ago
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _babyBirthDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake, color: AppColors.primaryPink),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _babyBirthDate != null
                            ? '${_babyBirthDate!.day}/${_babyBirthDate!.month}/${_babyBirthDate!.year}'
                            : 'Doğum Tarihi Seçin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              _babyBirthDate != null
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildReadyPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPink.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.primaryPink,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Hazır!',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _babyName.isNotEmpty
                ? '$_babyName\'in gelişim yolculuğuna başlamaya hazırız!'
                : 'Bebeğinizin gelişim yolculuğuna başlamaya hazırız!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textMedium,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.stars, color: AppColors.primaryPink, size: 32),
                const SizedBox(height: 12),
                Text(
                  'MiniMoni ile bebeğinizin her anını kaydedin, gelişimini takip edin ve kişiselleştirilmiş öneriler alın.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back Button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Geri'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          // Next/Finish Button
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              child: Text(
                _currentStep == _totalSteps - 1 ? 'Başlayalım!' : 'İleri',
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
      case 1:
        return true;
      case 2:
        return _babyName.isNotEmpty &&
            _babyGender.isNotEmpty &&
            _babyBirthDate != null;
      case 3:
        return true;
      default:
        return false;
    }
  }
}
