import 'package:flutter/material.dart';
import '../../models/shift.dart';
import '../../models/user.dart';
import '../../services/shift_service.dart';
import '../../theme.dart';
import 'add_shift_screen.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({
    super.key,
    required this.currentUser,
    this.mode = 'all',
  });

  // 'all' = rota management for Admin and Manager.
  // 'mine' = personal shifts for Care Worker.
  final String mode;
  final User currentUser;

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  final _service = ShiftService();
  List<Shift> _shifts = [];
  bool _loading = true;
  String? _error;

  bool get _canManage =>
      widget.currentUser.role == 'Administrator' ||
      widget.currentUser.role == 'Manager / Senior Carer';

  bool get _canDelete => widget.currentUser.role == 'Administrator';

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
      final list = widget.mode == 'mine'
          ? await _service.listMine()
          : await _service.listAll();
      if (!mounted) return;
      setState(() {
        _shifts = list;
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

  Future<void> _addOrEdit([Shift? existing]) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddShiftScreen(existing: existing)),
    );
    if (ok == true) _load();
  }

  Future<void> _delete(Shift s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete shift?'),
        content: Text(
          'Delete shift on ${s.shiftDate} for ${s.staffName ?? "staff"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.delete(s.id);
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mode == 'mine' ? 'My Shifts' : 'Shifts & Rota',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scheduled working shifts for staff.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (_canManage)
                ElevatedButton.icon(
                  onPressed: () => _addOrEdit(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Shift'),
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
          const SizedBox(height: 20),
          if (_shifts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('No shifts scheduled yet.',
                    style: TextStyle(color: AppColors.textMuted)),
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
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: const [
              Expanded(flex: 2, child: _HeaderCell('Date')),
              Expanded(flex: 2, child: _HeaderCell('Start')),
              Expanded(flex: 2, child: _HeaderCell('End')),
              Expanded(flex: 2, child: _HeaderCell('Type')),
              Expanded(flex: 3, child: _HeaderCell('Staff')),
              Expanded(flex: 2, child: _HeaderCell('Status')),
              SizedBox(width: 80),
            ],
          ),
        ),
        const Divider(height: 1),
        ..._shifts.map((s) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    s.shiftDate,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textDark),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(s.startTime,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textDark)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(s.endTime,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textDark)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(s.shiftType,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    s.staffName ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textDark),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _StatusPill(status: s.status),
                ),
                SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      if (_canManage)
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () => _addOrEdit(s),
                          icon: const Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.primary),
                        ),
                      if (_canDelete)
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _delete(s),
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: AppColors.danger),
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
      case 'scheduled':
        color = AppColors.primary;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.textMuted;
        break;
      case 'no_show':
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
        ),
      ),
    );
  }
}