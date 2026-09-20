import 'package:flutter/material.dart';
import '../../models/audit_log.dart';
import '../../services/audit_log_service.dart';
import '../../theme.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final _service = AuditLogService();
  List<AuditLog> _logs = [];
  bool _loading = true;
  String? _error;

  String? _actionFilter;
  String? _entityFilter;

  static const List<String> _actions = [
    'login',
    'create',
    'update',
    'delete',
    'record',
  ];

  static const List<String> _entities = [
    'user',
    'resident',
    'care_plan',
    'medication',
    'incident',
    'family_link',
    'staff',
  ];

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
      final list = await _service.list(
        action: _actionFilter,
        entityType: _entityFilter,
        limit: 200,
      );
      if (!mounted) return;
      setState(() {
        _logs = list;
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Logs',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Recent important actions in the system.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _filterDropdown(
                  label: 'Action',
                  value: _actionFilter,
                  options: _actions,
                  onChanged: (v) {
                    setState(() => _actionFilter = v);
                    _load();
                  },
                ),
                _filterDropdown(
                  label: 'Entity',
                  value: _entityFilter,
                  options: _entities,
                  onChanged: (v) {
                    setState(() => _entityFilter = v);
                    _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_logs.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No audit logs yet.',
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

  Widget _filterDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              hint: const Text('All'),
              onChanged: onChanged,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...options.map(
                  (o) => DropdownMenuItem(value: o, child: Text(o)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: const [
              Expanded(flex: 2, child: _HeaderCell('Time')),
              Expanded(flex: 2, child: _HeaderCell('User')),
              Expanded(flex: 2, child: _HeaderCell('Action')),
              Expanded(flex: 2, child: _HeaderCell('Entity')),
              Expanded(flex: 4, child: _HeaderCell('Description')),
            ],
          ),
        ),
        const Divider(height: 1),
        ..._logs.map((log) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    log.createdAt.replaceFirst('T', ' ').split('.').first,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.userName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      if (log.role != null)
                        Text(
                          log.role!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.none,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _ActionPill(action: log.action),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    log.entityType +
                        (log.entityId != null ? ' #${log.entityId}' : ''),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    log.description ?? '-',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark,
                      decoration: TextDecoration.none,
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
        decoration: TextDecoration.none,
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.action});
  final String action;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (action) {
      case 'create':
        color = AppColors.success;
        break;
      case 'update':
        color = AppColors.accent;
        break;
      case 'delete':
        color = AppColors.danger;
        break;
      case 'login':
        color = AppColors.primary;
        break;
      case 'record':
        color = AppColors.warning;
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
        action,
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