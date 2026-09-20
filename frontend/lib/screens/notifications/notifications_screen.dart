import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../models/user.dart';
import '../../services/notification_service.dart';
import '../../theme.dart';
import '../messages/messages_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.currentUser});
  final User currentUser;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<AppNotification> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.listMine();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllRead();
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _onTap(AppNotification n) async {
    if (n.isUnread) {
      try {
        await _service.markRead(n.id);
      } catch (_) {}
    }
    if (!mounted) return;

    // Route based on the notification's link field.
    if (n.link == 'messages') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MessagesScreen(currentUser: widget.currentUser),
        ),
      ).then((_) => _load());
      return;
    }

    // Default: just mark as read and refresh.
    _load();
  }

  Future<void> _delete(AppNotification n) async {
    try {
      await _service.delete(n.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 42, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final int unread = _items.where((n) => n.isUnread).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unread == 0
                          ? 'No unread notifications.'
                          : '$unread unread notification${unread == 1 ? '' : 's'}.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread > 0)
                OutlinedButton.icon(
                  onPressed: _markAllRead,
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Mark all read'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ..._items.map(_buildCard),
        ],
      ),
    );
  }

  Widget _buildCard(AppNotification n) {
    return GestureDetector(
      onTap: () => _onTap(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: n.isUnread ? AppColors.primary : AppColors.border,
            width: n.isUnread ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _iconColor(n.type).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconFor(n.type),
                size: 16,
                color: _iconColor(n.type),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: n.isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (n.isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'New',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _delete(n),
                        icon: const Icon(Icons.delete_outline,
                            size: 16, color: AppColors.danger),
                      ),
                    ],
                  ),
                  if (n.body != null && n.body!.isNotEmpty)
                    Text(
                      n.body!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    n.createdAt,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
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

  IconData _iconFor(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_outline;
      case 'task':
        return Icons.checklist_outlined;
      case 'medication':
        return Icons.medication_outlined;
      case 'incident':
        return Icons.warning_amber_outlined;
      case 'care_plan':
        return Icons.assignment_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'message':
        return AppColors.primary;
      case 'task':
        return AppColors.accent;
      case 'medication':
        return AppColors.success;
      case 'incident':
        return AppColors.danger;
      case 'care_plan':
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }
}