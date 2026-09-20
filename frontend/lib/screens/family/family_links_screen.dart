import 'package:flutter/material.dart';
import '../../models/family_link.dart';
import '../../models/resident.dart';
import '../../models/user.dart';
import '../../services/family_service.dart';
import '../../services/resident_service.dart';
import '../../services/user_service.dart';
import '../../theme.dart';

// Lists all family-resident links. Admin and Manager only.
class FamilyLinksScreen extends StatefulWidget {
  const FamilyLinksScreen({super.key});

  @override
  State<FamilyLinksScreen> createState() => _FamilyLinksScreenState();
}

class _FamilyLinksScreenState extends State<FamilyLinksScreen> {
  final FamilyService _familyService = FamilyService();
  final ResidentService _residentService = ResidentService();
  final UserService _userService = UserService();

  List<FamilyLink> _links = [];
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
      final links = await _familyService.listLinks();
      if (!mounted) return;
      setState(() {
        _links = links;
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

  Future<void> _addLink() async {
    final residents = await _residentService.listResidents();
    final familyUsers = await _userService.listByRole('Family Member');
    if (!mounted) return;

    if (residents.isEmpty || familyUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create at least one resident and one family member first.',
          ),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddLinkDialog(
        residents: residents,
        familyUsers: familyUsers,
        onSave: (residentId, userId, relationship, isPrimary) async {
          await _familyService.createLink(
            userId: userId,
            residentId: residentId,
            relationship: relationship,
            isPrimary: isPrimary,
          );
        },
      ),
    );

    if (result == true) _load();
  }

  Future<void> _deleteLink(FamilyLink link) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove link?'),
        content: Text(
          'Remove the link between ${link.userName} and ${link.residentName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _familyService.deleteLink(link.id);
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

    return SingleChildScrollView(
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
                      'Family Links',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Link family member accounts to residents.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addLink,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Link'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: _links.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No family links yet.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  )
                : _buildTable(),
          ),
        ],
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
              Expanded(flex: 3, child: _HeaderCell('Family Member')),
              Expanded(flex: 3, child: _HeaderCell('Resident')),
              Expanded(child: _HeaderCell('Room')),
              Expanded(flex: 2, child: _HeaderCell('Relationship')),
              Expanded(child: _HeaderCell('Primary')),
              SizedBox(width: 40, child: SizedBox()),
            ],
          ),
        ),
        const Divider(height: 1),
        ..._links.map((l) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        l.userEmail,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    l.residentName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l.residentRoom ?? '-',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l.relationship ?? '-',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: l.isPrimary
                      ? const Icon(Icons.check,
                          size: 16, color: AppColors.success)
                      : const Text('-'),
                ),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    tooltip: 'Remove link',
                    onPressed: () => _deleteLink(l),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppColors.danger,
                    ),
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
      ),
    );
  }
}

// Dialog to create a new family link.
class _AddLinkDialog extends StatefulWidget {
  const _AddLinkDialog({
    required this.residents,
    required this.familyUsers,
    required this.onSave,
  });

  final List<Resident> residents;
  final List<User> familyUsers;
  final Future<void> Function(
    int residentId,
    int userId,
    String? relationship,
    bool isPrimary,
  ) onSave;

  @override
  State<_AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<_AddLinkDialog> {
  late int _residentId = widget.residents.first.id;
  late int _userId = widget.familyUsers.first.id;
  final _relationship = TextEditingController();
  bool _isPrimary = false;
  bool _saving = false;

  @override
  void dispose() {
    _relationship.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _residentId,
        _userId,
        _relationship.text.trim().isEmpty
            ? null
            : _relationship.text.trim(),
        _isPrimary,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Family Link'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resident',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _residentId,
              isExpanded: true,
              items: widget.residents
                  .map((r) => DropdownMenuItem(
                        value: r.id,
                        child: Text('${r.fullName} (Room ${r.room ?? '-'})'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _residentId = v!),
            ),
            const SizedBox(height: 12),
            const Text('Family Member',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _userId,
              isExpanded: true,
              items: widget.familyUsers
                  .map((u) => DropdownMenuItem(
                        value: u.id,
                        child: Text('${u.fullName} (${u.email})'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _userId = v!),
            ),
            const SizedBox(height: 12),
            const Text('Relationship',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            TextField(
              controller: _relationship,
              decoration: const InputDecoration(
                hintText: 'Daughter, Son, Spouse, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _isPrimary,
                  onChanged: (v) => setState(() => _isPrimary = v ?? false),
                  activeColor: AppColors.primary,
                ),
                const Text('Primary contact',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}