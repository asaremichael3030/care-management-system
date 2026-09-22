import 'package:flutter/material.dart';
import '../../models/resident.dart';
import '../../models/risk_assessment.dart';
import '../../models/user.dart';
import '../../services/resident_service.dart';
import '../../services/risk_assessment_service.dart';
import '../../services/user_service.dart';
import '../../theme.dart';

class AddRiskAssessmentScreen extends StatefulWidget {
  const AddRiskAssessmentScreen({super.key, this.existing});

  final RiskAssessment? existing;

  @override
  State<AddRiskAssessmentScreen> createState() =>
      _AddRiskAssessmentScreenState();
}

class _AddRiskAssessmentScreenState extends State<AddRiskAssessmentScreen> {
  final _service = RiskAssessmentService();
  final _residentService = ResidentService();
  final _userService = UserService();

  final _description = TextEditingController();
  final _mitigation = TextEditingController();
  final _reviewDate = TextEditingController();

  int? _residentId;
  int? _assessedBy;
  String _riskType = 'Falls Risk';
  String _riskLevel = 'low';
  String _status = 'active';

  List<Resident> _residents = [];
  List<User> _staff = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  static const List<String> _riskTypes = [
    'Falls Risk', 'Mobility Risk', 'Nutrition Risk',
    'Pressure Area Risk', 'General Safety Risk', 'Medication Risk', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    final e = widget.existing;
    if (e != null) {
      _description.text = e.description ?? '';
      _mitigation.text = e.mitigation ?? '';
      _reviewDate.text = e.reviewDate ?? '';
      _riskType = _riskTypes.contains(e.riskType) ? e.riskType : 'Other';
      _riskLevel = e.riskLevel;
      _status = e.status;
      _residentId = e.residentId;
      _assessedBy = e.assessedBy;
    }
  }

  Future<void> _load() async {
    try {
      final r = await _residentService.listResidents();
      final cw = await _userService.listByRole('Care Worker');
      final mg = await _userService.listByRole('Manager / Senior Carer');
      if (!mounted) return;
      setState(() {
        _residents = r;
        _staff = [...mg, ...cw];
        _residentId ??= r.isNotEmpty ? r.first.id : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _description.dispose();
    _mitigation.dispose();
    _reviewDate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_residentId == null) {
      setState(() => _error = 'Resident is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final payload = {
      'resident_id': _residentId,
      'risk_type': _riskType,
      'risk_level': _riskLevel,
      'description':
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      'mitigation':
          _mitigation.text.trim().isEmpty ? null : _mitigation.text.trim(),
      'review_date':
          _reviewDate.text.trim().isEmpty ? null : _reviewDate.text.trim(),
      'status': _status,
      'assessed_by': _assessedBy,
    };
    try {
      if (_isEdit) {
        await _service.update(widget.existing!.id, payload);
      } else {
        await _service.create(payload);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_residents.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
              _isEdit ? 'Edit Risk Assessment' : 'Add Risk Assessment',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.surface,
        ),
        body: const _NoResidents(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Risk Assessment' : 'Add Risk Assessment',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _residentDropdown(),
              _row([_riskTypeDropdown(), _riskLevelDropdown()]),
              _statusDropdown(),
              _field('Description', _description, lines: 3),
              _field('Mitigation / Actions in Place', _mitigation, lines: 3),
              _row([
                _field('Review Date (YYYY-MM-DD)', _reviewDate),
                _staffDropdown(),
              ]),
              if (_error != null) ...[
                const SizedBox(height: 12),
                _errorBox(_error!),
              ],
              const SizedBox(height: 20),
              _actionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i != children.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLines: lines,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _residentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resident',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _residentId,
                isExpanded: true,
                hint: const Text('Select a resident',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textMuted)),
                onChanged: (v) => setState(() => _residentId = v),
                items: _residents
                    .map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(
                            '${r.fullName} (Room ${r.room ?? '-'})',
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

  Widget _riskTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Risk Type',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _riskType,
                isExpanded: true,
                onChanged: (v) => setState(() => _riskType = v!),
                items: _riskTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child:
                              Text(t, style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskLevelDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Risk Level',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _riskLevel,
                isExpanded: true,
                onChanged: (v) => setState(() => _riskLevel = v!),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('low')),
                  DropdownMenuItem(value: 'medium', child: Text('medium')),
                  DropdownMenuItem(value: 'high', child: Text('high')),
                  DropdownMenuItem(value: 'critical', child: Text('critical')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _status,
                isExpanded: true,
                onChanged: (v) => setState(() => _status = v!),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('active')),
                  DropdownMenuItem(
                      value: 'under_review', child: Text('under review')),
                  DropdownMenuItem(value: 'closed', child: Text('closed')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assessed By',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _assessedBy,
                isExpanded: true,
                hint: const Text('Unassigned',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textMuted)),
                onChanged: (v) => setState(() => _assessedBy = v),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Unassigned')),
                  ..._staff.map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.fullName} (${s.role})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14)),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed:
                  _saving ? null : () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textDark,
              ),
              child: const Text('Cancel'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_isEdit ? 'Update' : 'Save'),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoResidents extends StatelessWidget {
  const _NoResidents();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text('No residents yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text(
              'Add a resident first, then you can add risk assessments.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}