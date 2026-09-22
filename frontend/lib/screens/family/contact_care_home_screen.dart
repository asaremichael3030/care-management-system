import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/message_service.dart';
import '../../theme.dart';

// Family members send a message to a staff member at the care home.
// The reply appears in their Messages inbox.
class ContactCareHomeScreen extends StatefulWidget {
  const ContactCareHomeScreen({super.key});

  @override
  State<ContactCareHomeScreen> createState() => _ContactCareHomeScreenState();
}

class _ContactCareHomeScreenState extends State<ContactCareHomeScreen> {
  final _service = MessageService();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  bool _loadingContacts = true;
  bool _sending = false;
  List<Contact> _contacts = [];
  Contact? _recipient;
  String? _success;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final list = await _service.contacts();
      if (!mounted) return;
      setState(() {
        _contacts = list;
        // Prefer an Administrator or Manager.
        Contact? preferred;
        for (final c in list) {
          if (c.role == 'Administrator' || c.role == 'Manager / Senior Carer') {
            preferred = c;
            break;
          }
        }
        _recipient = preferred ?? (list.isNotEmpty ? list.first : null);
        _loadingContacts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingContacts = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _send() async {
    if (_recipient == null) {
      setState(() => _error = 'No care team contact is available.');
      return;
    }
    if (_message.text.trim().isEmpty) {
      setState(() => _error = 'Please write your message.');
      return;
    }

    setState(() {
      _sending = true;
      _success = null;
      _error = null;
    });

    try {
      await _service.send(
        recipientId: _recipient!.id,
        subject: _subject.text.trim().isEmpty
            ? 'Message from family'
            : _subject.text.trim(),
        body: _message.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _success =
            'Your message has been sent to ${_recipient!.fullName}. You will see the reply in your Messages inbox.';
        _subject.clear();
        _message.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Care Home',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Send a message to the care home team.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 20),
            if (_loadingContacts)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _dropdownRecipient(),
                    _field('Subject', _subject),
                    _field('Message', _message, lines: 6),
                    if (_success != null) ...[
                      const SizedBox(height: 12),
                      _infoBox(_success!, success: true),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _infoBox(_error!, success: false),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            (_sending || _recipient == null) ? null : _send,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _sending
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Send Message',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600),
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

  Widget _dropdownRecipient() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send to',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _recipient?.id,
                isExpanded: true,
                hint: const Text(
                  'Select a recipient',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textMuted),
                ),
                onChanged: (v) {
                  setState(() {
                    _recipient = _contacts.firstWhere((c) => c.id == v);
                  });
                },
                items: _contacts
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            '${c.fullName} (${c.role})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLines: lines,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String msg, {required bool success}) {
    final Color color =
        success ? AppColors.success : AppColors.danger;
    final IconData icon =
        success ? Icons.check_circle_outline : Icons.error_outline;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}