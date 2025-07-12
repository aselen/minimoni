import 'package:flutter/material.dart';
import '../../core/services/feeding_notification_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/baby_model.dart';
import '../../core/services/baby_storage_service.dart';
import '../../app/theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<FeedingNotificationModel> _allNotifications = [];
  List<FeedingNotificationModel> _filteredNotifications = [];
  List<BabyModel> _babies = [];
  String? _selectedBabyId;
  FeedingNotificationType? _selectedType;
  bool _showOnlyUnread = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Bebekleri yükle
      _babies = await BabyStorageService.instance.getAllBabies();

      // Tüm bildirimleri yükle
      _allNotifications = [];
      for (final baby in _babies) {
        final babyNotifications = await FeedingNotificationService.instance
            .getNotificationsForBaby(baby.id);
        _allNotifications.addAll(babyNotifications);
      }

      // Tarihe göre sırala
      _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _applyFilters();
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    _filteredNotifications =
        _allNotifications.where((notification) {
          // Bebek filtresi
          if (_selectedBabyId != null &&
              notification.babyId != _selectedBabyId) {
            return false;
          }

          // Tip filtresi
          if (_selectedType != null && notification.type != _selectedType) {
            return false;
          }

          // Okunmamış filtresi
          if (_showOnlyUnread && notification.isRead) {
            return false;
          }

          return true;
        }).toList();
  }

  Future<void> _markAsRead(FeedingNotificationModel notification) async {
    await FeedingNotificationService.instance.markAsRead(notification.id);
    await _loadData();
  }

  Future<void> _deleteNotification(
    FeedingNotificationModel notification,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Bildirimi Sil'),
            content: const Text(
              'Bu bildirimi silmek istediğinizden emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FeedingNotificationService.instance.deleteNotification(
        notification.id,
      );
      await _loadData();
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tüm Bildirimleri Temizle'),
            content: const Text(
              'Tüm bildirimleri silmek istediğinizden emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Temizle'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FeedingNotificationService.instance.clearAllNotifications();
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearAllNotifications,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Tümünü Temizle',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Uyarılar'),
            Tab(text: 'Kilometre Taşları'),
            Tab(text: 'İpuçları'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtreler
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Bebek filtresi
                if (_babies.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedBabyId,
                    decoration: const InputDecoration(
                      labelText: 'Bebek Seçin',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tüm Bebekler'),
                      ),
                      ..._babies.map(
                        (baby) => DropdownMenuItem(
                          value: baby.id,
                          child: Text(baby.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBabyId = value;
                        _applyFilters();
                      });
                    },
                  ),
                const SizedBox(height: 12),

                // Diğer filtreler
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Sadece Okunmamış'),
                        value: _showOnlyUnread,
                        onChanged: (value) {
                          setState(() {
                            _showOnlyUnread = value ?? false;
                            _applyFilters();
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Yenile',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bildirim listesi
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz bildirim yok',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Bildirimler burada görünecek',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        final baby = _babies.firstWhere(
          (b) => b.id == notification.babyId,
          orElse:
              () => BabyModel(
                id: 'unknown',
                name: 'Bilinmeyen Bebek',
                birthDate: DateTime.now(),
                gender: 'unknown',
              ),
        );

        return _buildNotificationCard(notification, baby);
      },
    );
  }

  Widget _buildNotificationCard(
    FeedingNotificationModel notification,
    BabyModel baby,
  ) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 4 : 2,
      color: isUnread ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Text(notification.emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  baby.name,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'mark_read':
                if (isUnread) {
                  await _markAsRead(notification);
                }
                break;
              case 'delete':
                await _deleteNotification(notification);
                break;
            }
          },
          itemBuilder:
              (context) => [
                if (isUnread)
                  const PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text('Okundu Olarak İşaretle'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sil', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () async {
          if (isUnread) {
            await _markAsRead(notification);
          }
          // Bildirim detaylarını göster
          _showNotificationDetails(notification, baby);
        },
      ),
    );
  }

  Color _getNotificationColor(FeedingNotificationType type) {
    switch (type) {
      case FeedingNotificationType.frequencyWarning:
        return Colors.orange;
      case FeedingNotificationType.amountWarning:
        return Colors.red;
      case FeedingNotificationType.milestone:
        return Colors.green;
      case FeedingNotificationType.tip:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  void _showNotificationDetails(
    FeedingNotificationModel notification,
    BabyModel baby,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Text(notification.emoji),
                const SizedBox(width: 8),
                Expanded(child: Text(notification.title)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 16),
                Text(
                  'Bebek: ${baby.name}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tarih: ${_formatDetailedDate(notification.createdAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (notification.metadata != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Detaylar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...notification.metadata!.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('${entry.key}: ${entry.value}'),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ],
          ),
    );
  }

  String _formatDetailedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
