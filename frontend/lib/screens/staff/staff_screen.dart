import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/staff.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/staff_service.dart';
import '../../theme.dart';
import 'add_staff_screen.dart';
import 'edit_staff_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({
    super.key,
    required this.currentUser,
    this.filterRole,
  });

  final User currentUser;
  final String? filterRole;

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _service = StaffService();
  List<Staff> _staff = [];
  bool _loading = true;
  String? _error;

  bool get _canCreate => widget.currentUser.role == 'Administrator';
  bool get _canEdit =>
      widget.currentUser.role == 'Administrator' ||
      widget.currentUser.role == 'Manager / Senior Carer';

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
      final list = await _service.listAll(role: widget.filterRole);
      if (!mounted) return;
      setState(() {
        _staff = list;
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

  void _success(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _add() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AddStaffScreen()),
    );
    if (result == null) return;
    _success(result);
    _load();
  }

  Future<void> _invite() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _InviteStaffDialog(),
    );
    if (ok == true) {
      _success('Invitation sent. The user must accept it before logging in.');
      _load();
    }
  }

  Future<void> _edit(Staff s) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => EditStaffScreen(staff: s)),
    );
    if (result == null) return;
    _success(result);
    _load();
  }

  Future<void> _delete(Staff s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Remove staff member?',
          style: TextStyle(decoration: TextDecoration.none),
        ),
        content: Text(
          'This will delete ${s.fullName} and their user account. Continue?',
          style: const TextStyle(decoration: TextDecoration.none),
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
    if (confirmed != true) return;
    try {
      await _service.delete(s.id);
      _success('Staff member removed.');
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

    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
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
                      Text(
                        widget.filterRole == 'Care Worker'
                            ? 'Care Workers'
                            : 'Staff',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Staff members and employment details.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_canCreate) ...[
                  OutlinedButton.icon(
                    onPressed: _invite,
                    icon: const Icon(Icons.mail_outline, size: 16),
                    label: const Text('Invite Staff'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Staff'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            if (_staff.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No staff members yet.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: _buildTable(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: const [
              Expanded(flex: 3, child: _HeaderCell('Name')),
              Expanded(flex: 3, child: _HeaderCell('Email')),
              Expanded(flex: 2, child: _HeaderCell('Role')),
              Expanded(flex: 2, child: _HeaderCell('Status')),
              Expanded(flex: 2, child: _HeaderCell('Department')),
              SizedBox(width: 80),
            ],
          ),
        ),
        const Divider(height: 1),
        ..._staff.map((s) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    s.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    s.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    s.role,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _StatusPill(status: s.employmentStatus),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    s.department ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_canEdit)
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () => _edit(s),
                          icon: const Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.primary),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (_canCreate)
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _delete(s),
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: AppColors.danger),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        decoration: TextDecoration.none,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'active':
        color = AppColors.success;
        break;
      case 'on_leave':
        color = AppColors.warning;
        break;
      case 'suspended':
        color = AppColors.danger;
        break;
      default:
        color = AppColors.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _InviteStaffDialog extends StatefulWidget {
  const _InviteStaffDialog();

  @override
  State<_InviteStaffDialog> createState() => _InviteStaffDialogState();
}

class _InviteStaffDialogState extends State<_InviteStaffDialog> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  String _role = 'Care Worker';
  bool _saving = false;
  String? _error;

  static const List<String> _roles = [
    'Administrator',
    'Manager / Senior Carer',
    'Care Worker',
    'Family Member',
  ];

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        _email.text.trim().isEmpty) {
      setState(() =>
          _error = 'First name, last name, and email are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final token = await AuthService().getToken();
      final r = await http.post(
        Uri.parse('${AuthService.baseUrl}/api/invitations/send'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'first_name': _firstName.text.trim(),
          'last_name': _lastName.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          'role': _role,
        }),
      );
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      if (r.statusCode != 201) {
        setState(() {
          _error =
              body['message']?.toString() ?? 'Could not send invitation.';
          _saving = false;
        });
        return;
      }
      if (!mounted) return;
      final devLink = body['devLink'] as String?;
      Navigator.pop(context, true);
      if (devLink != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dev link: $devLink'),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Invite Staff',
        style: TextStyle(decoration: TextDecoration.none),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('First Name', _firstName),
              _field('Last Name', _lastName),
              _field('Email', _email),
              _field('Phone (optional)', _phone),
              const Text(
                'Role',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _role,
                    isExpanded: true,
                    onChanged: (v) => setState(() => _role = v!),
                    items: _roles
                        .map((r) =>
                            DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The user will receive an email with a link to set their password.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(decoration: TextDecoration.none),
          ),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _send,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Send Invitation',
                  style: TextStyle(decoration: TextDecoration.none),
                ),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}