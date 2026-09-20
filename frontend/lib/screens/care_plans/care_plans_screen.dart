import 'package:flutter/material.dart';
import '../../models/care_plan.dart';
import '../../models/user.dart';
import '../../services/care_plan_service.dart';
import '../../theme.dart';
import 'add_care_plan_screen.dart';

// Care plans list. Embedded in the dashboard content area.
class CarePlansScreen extends StatefulWidget {
  const CarePlansScreen({
    super.key,
    required this.currentUser,
    this.residentId,
  });

  final User currentUser;
  final int? residentId;

  @override
  State<CarePlansScreen> createState() => _CarePlansScreenState();
}

class _CarePlansScreenState extends State<CarePlansScreen> {
  final CarePlanService _service = CarePlanService();
  List<CarePlan> _plans = [];
  bool _loading = true;
  String? _error;

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
      final list = widget.residentId != null
          ? await _service.listByResident(widget.residentId!)
          : await _service.listCarePlans();
      if (!mounted) return;
      setState(() {
        _plans = list;
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

  Future<void> _addOrEdit([CarePlan? existing]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCarePlanScreen(
          existing: existing,
          fixedResidentId: widget.residentId,
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _delete(CarePlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete care plan?'),
        content: Text('Delete "${plan.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deleteCarePlan(plan.id);
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
                      'Care Plans',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Personalised care plans for each resident.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (_canEdit)
                ElevatedButton.icon(
                  onPressed: () => _addOrEdit(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Care Plan'),
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
          ),
          const SizedBox(height: 20),
          if (_plans.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  'No care plans yet.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ..._plans.map(_buildCard),
        ],
      ),
    );
  }

  Widget _buildCard(CarePlan p) {
    Color statusColor;
    switch (p.status) {
      case 'active':
        statusColor = AppColors.success;
        break;
      case 'under_review':
        statusColor = AppColors.warning;
        break;
      case 'completed':
        statusColor = AppColors.primary;
        break;
      default:
        statusColor = AppColors.textMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
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
                      p.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (p.residentName != null)
                      Text(
                        '${p.residentName} . Room ${p.residentRoom ?? '-'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p.status.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              if (_canEdit)
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _addOrEdit(p),
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.primary),
                ),
              if (widget.currentUser.role == 'Administrator')
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _delete(p),
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: AppColors.danger),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _line('Care Need', p.careNeed),
          _line('Goal', p.goal),
          _line('Care Actions', p.careActions),
          _line('Frequency', p.frequency),
          _line('Assigned Staff', p.staffName),
          Row(
            children: [
              Expanded(child: _line('Start Date', p.startDate)),
              Expanded(child: _line('Review Date', p.reviewDate)),
            ],
          ),
          if (p.notes != null && p.notes!.isNotEmpty)
            _line('Notes', p.notes),
        ],
      ),
    );
  }

  Widget _line(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}