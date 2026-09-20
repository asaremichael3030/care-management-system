import 'package:flutter/material.dart';
import '../../models/risk_assessment.dart';
import '../../models/user.dart';
import '../../services/risk_assessment_service.dart';
import '../../theme.dart';
import 'add_risk_assessment_screen.dart';

class RiskAssessmentsScreen extends StatefulWidget {
  const RiskAssessmentsScreen({
    super.key,
    required this.currentUser,
    this.residentId,
  });

  final User currentUser;
  final int? residentId;

  @override
  State<RiskAssessmentsScreen> createState() => _RiskAssessmentsScreenState();
}

class _RiskAssessmentsScreenState extends State<RiskAssessmentsScreen> {
  final _service = RiskAssessmentService();
  List<RiskAssessment> _risks = [];
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
      final list = await _service.listAll(residentId: widget.residentId);
      if (!mounted) return;
      setState(() {
        _risks = list;
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

  Future<void> _addOrEdit([RiskAssessment? existing]) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRiskAssessmentScreen(existing: existing),
      ),
    );
    if (ok == true) _load();
  }

  Future<void> _delete(RiskAssessment r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete risk assessment?'),
        content: Text('Delete "${r.riskType}" for ${r.residentName ?? 'resident'}?'),
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
      await _service.delete(r.id);
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
              const Icon(Icons.error_outline, size: 42, color: AppColors.danger),
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
                      'Risk Assessments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Risks identified for residents and actions in place.',
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
                  label: const Text('Add Assessment'),
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
          if (_risks.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('No risk assessments yet.',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ..._risks.map(_buildCard),
        ],
      ),
    );
  }

  Widget _buildCard(RiskAssessment r) {
    Color levelColor;
    switch (r.riskLevel) {
      case 'critical':
        levelColor = AppColors.danger;
        break;
      case 'high':
        levelColor = AppColors.warning;
        break;
      case 'medium':
        levelColor = AppColors.accent;
        break;
      default:
        levelColor = AppColors.success;
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
                      r.riskType,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (r.residentName != null)
                      Text(
                        '${r.residentName} . Room ${r.residentRoom ?? '-'}',
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
                  color: levelColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.riskLevel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: levelColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.status.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              if (_canEdit)
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _addOrEdit(r),
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.primary),
                ),
              if (widget.currentUser.role == 'Administrator')
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _delete(r),
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: AppColors.danger),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _line('Description', r.description),
          _line('Mitigation', r.mitigation),
          _line('Review Date', r.reviewDate),
          _line('Assessed By', r.assessedByName),
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