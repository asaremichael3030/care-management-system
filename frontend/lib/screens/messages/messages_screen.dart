import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/message_service.dart';
import '../../theme.dart';
import 'compose_message_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.currentUser});
  final User currentUser;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _service = MessageService();
  List<Message> _inbox = [];
  List<Message> _sent = [];
  int _tabIndex = 0;
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
      final inbox = await _service.inbox();
      final sent = await _service.sent();
      if (!mounted) return;
      setState(() {
        _inbox = inbox;
        _sent = sent;
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

  Future<void> _compose() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ComposeMessageScreen()),
    );
    if (ok == true) _load();
  }

  Future<void> _openMessage(Message m) async {
    if (m.isUnread) {
      try {
        await _service.markRead(m.id);
      } catch (_) {}
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          m.subject?.isNotEmpty == true ? m.subject! : '(no subject)',
          style: const TextStyle(decoration: TextDecoration.none),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'From: ${m.senderName}  ${m.senderRole ?? ''}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                m.body,
                style: const TextStyle(
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(decoration: TextDecoration.none),
            ),
          ),
        ],
      ),
    ).then((_) => _load());
  }

  Future<void> _delete(Message m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete message?',
          style: TextStyle(decoration: TextDecoration.none),
        ),
        content: const Text(
          'This message will be removed from the system.',
          style: TextStyle(decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(decoration: TextDecoration.none),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.danger,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.delete(m.id);
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
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
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final messages = _tabIndex == 0 ? _inbox : _sent;

    // Material wrapper stops the Flutter Web HTML renderer from
    // underlining text on hover.
    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Communicate with the care home.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _compose,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('New Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _tabButton('Inbox', 0),
                const SizedBox(width: 8),
                _tabButton('Sent', 1),
              ],
            ),
            const SizedBox(height: 16),
            if (messages.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No messages yet.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              )
            else
              ...messages.map((m) => _buildCard(m)),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final bool active = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textDark,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Message m) {
    final bool inbox = _tabIndex == 0;
    final String name = inbox ? m.senderName : m.recipientName;
    final String role = (inbox ? m.senderRole : m.recipientRole) ?? '';

    return GestureDetector(
      onTap: () => _openMessage(m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: inbox && m.isUnread ? AppColors.primary : AppColors.border,
            width: inbox && m.isUnread ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      if (role.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          role,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                      if (inbox && m.isUnread) ...[
                        const SizedBox(width: 8),
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
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _delete(m),
                        icon: const Icon(Icons.delete_outline,
                            size: 16, color: AppColors.danger),
                      ),
                    ],
                  ),
                  Text(
                    m.subject?.isNotEmpty == true ? m.subject! : '(no subject)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.none,
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
}