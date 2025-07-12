import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/models/sleep_notification_model.dart';
import '../../core/services/sleep_notification_service.dart';
import '../../core/providers/baby_providers.dart';
import '../../shared/widgets/modern_header.dart';
import '../memory/memory_providers.dart';

class SleepNotificationPage extends ConsumerStatefulWidget {
  const SleepNotificationPage({super.key});

  @override
  ConsumerState<SleepNotificationPage> createState() =>
      _SleepNotificationPageState();
}

class _SleepNotificationPageState extends ConsumerState<SleepNotificationPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<SleepNotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadNotifications();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final baby = await ref.read(activeBabyProvider.future);
      if (baby != null) {
        final notifications = await SleepNotificationService.instance
            .getNotificationsForBaby(baby.id);

        if (mounted) {
          setState(() {
            _notifications = notifications;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(SleepNotificationModel notification) async {
    await SleepNotificationService.instance.markAsRead(notification.id);
    await _loadNotifications();
  }

  Future<void> _deleteNotification(SleepNotificationModel notification) async {
    await SleepNotificationService.instance.deleteNotification(notification.id);
    await _loadNotifications();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
    });
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          ModernHeader(
            title: 'Akıllı Uyku Uyarıları',
            subtitle: 'MiniMoni\'nin önerileri',
            emoji: '💤',
            showBackButton: true,
            isDashboard: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isLoading)
                  _buildLoadingState()
                else if (_notifications.isEmpty)
                  _buildEmptyState()
                else
                  _buildNotificationsList(),
              ]),
            ),
          ),
        ],
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
            'Bildirimler yükleniyor...',
            style: TextStyle(color: AppColors.textMedium, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 60,
                color: AppColors.primaryPink,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz Bildirim Yok',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'MiniMoni bebeğinizin uyku düzenini analiz ettikçe\nakıllı öneriler sunacak',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMedium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryPink,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Uyku takibi yaptıkça akıllı uyarılar alacaksınız',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bildirimler (${_notifications.length})',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: _refreshNotifications,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text('Yenile', style: GoogleFonts.inter(fontSize: 14)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildNotificationCard(_notifications[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(SleepNotificationModel notification) {
    final color = Color(
      int.parse(notification.colorHex.replaceAll('#', '0xFF')),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
        border: Border.all(
          color:
              notification.isRead
                  ? Colors.grey.withOpacity(0.2)
                  : color.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _markAsRead(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          notification.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification.type.displayName,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notification.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTimeAgo(notification.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    Row(
                      children: [
                        if (!notification.isRead)
                          TextButton(
                            onPressed: () => _markAsRead(notification),
                            child: Text(
                              'Okundu',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.primaryPink,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _deleteNotification(notification),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.textLight,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
