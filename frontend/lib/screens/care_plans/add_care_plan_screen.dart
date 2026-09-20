import 'package:flutter/material.dart';
import '../../models/care_plan.dart';
import '../../models/resident.dart';
import '../../models/user.dart';
import '../../services/care_plan_service.dart';
import '../../services/resident_service.dart';
import '../../services/user_service.dart';
import '../../theme.dart';

// Add or edit a care plan.
class AddCarePlanScreen extends StatefulWidget {
  const AddCarePlanScreen({
    super.key,
    this.existing,
    this.fixedResidentId,
  });

  final CarePlan? existing;
  final int? fixedResidentId;

  @override
  State<AddCarePlanScreen> createState() => _AddCarePlanScreenState();
}

class _AddCarePlanScreenState extends State<AddCarePlanScreen> {
  final CarePlanService _service = CarePlanService();
  final ResidentService _residentService = ResidentService();
  final UserService _userService = UserService();

  final _title = TextEditingController();
  final _careNeed = TextEditingController();
  final _goal = TextEditingController();
  final _careActions = TextEditingController();
  final _frequency = TextEditingController();
  final _startDate = TextEditingController();
  final _reviewDate = TextEditingController();
  final _notes = TextEditingController();

  int? _residentId;
  int? _assignedStaffId;
  String _status = 'active';

  List<Resident> _residents = [];
  List<User> _staff = [];
  bool _loading = true;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _careNeed.text = e.careNeed ?? '';
      _goal.text = e.goal ?? '';
      _careActions.text = e.careActions ?? '';
      _frequency.text = e.frequency ?? '';
      _startDate.text = e.startDate ?? '';
      _reviewDate.text = e.reviewDate ?? '';
      _notes.text = e.notes ?? '';
      _status = e.status;
      _residentId = e.residentId;
      _assignedStaffId = e.assignedStaffId;
    } else if (widget.fixedResidentId != null) {
      _residentId = widget.fixedResidentId;
    }
  }

  Future<void> _loadDependencies() async {
    try {
      final residents = await _residentService.listResidents();
      final workers = await _userService.listByRole('Care Worker');
      final managers = await _userService.listByRole('Manager / Senior Carer');
      if (!mounted) return;
      setState(() {
        _residents = residents;
        _staff = [...managers, ...workers];
        _residentId ??= residents.isNotEmpty ? residents.first.id : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _careNeed.dispose();
    _goal.dispose();
    _careActions.dispose();
    _frequency.dispose();
    _startDate.dispose();
    _reviewDate.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_residentId == null || _title.text.trim().isEmpty) {
      _showMessage('Resident and title are required.');
      return;
    }

    setState(() => _saving = true);

    final payload = {
      'resident_id': _residentId,
      'title': _title.text.trim(),
      'care_need': _careNeed.text.trim().isEmpty ? null : _careNeed.text.trim(),
      'goal': _goal.text.trim().isEmpty ? null : _goal.text.trim(),
      'care_actions':
          _careActions.text.trim().isEmpty ? null : _careActions.text.trim(),
      'frequency':
          _frequency.text.trim().isEmpty ? null : _frequency.text.trim(),
      'assigned_staff_id': _assignedStaffId,
      'start_date':
          _startDate.text.trim().isEmpty ? null : _startDate.text.trim(),
      'review_date':
          _reviewDate.text.trim().isEmpty ? null : _reviewDate.text.trim(),
      'status': _status,
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    };

    try {
      if (_isEdit) {
        await _service.updateCarePlan(widget.existing!.id, payload);
      } else {
        await _service.createCarePlan(payload);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Care Plan' : 'Add Care Plan',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dropdownResident(),
              _row([
                _field('Care Plan Title', _title),
                _dropdownStatus(),
              ]),
              _field('Care Need', _careNeed, lines: 2),
              _field('Goal', _goal, lines: 2),
              _field('Care Actions', _careActions, lines: 3),
              _row([
                _field('Frequency', _frequency),
                _dropdownStaff(),
              ]),
              _row([
                _field('Start Date (YYYY-MM-DD)', _startDate),
                _field('Review Date (YYYY-MM-DD)', _reviewDate),
              ]),
              _field('Notes', _notes, lines: 3),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(_isEdit ? 'Update' : 'Save'),
                      ),
                    ),
                  ),
                ],
              ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
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

  Widget _dropdownResident() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resident',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
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
              child: DropdownButton<int>(
                value: _residentId,
                isExpanded: true,
                onChanged: widget.fixedResidentId != null
                    ? null
                    : (v) => setState(() => _residentId = v),
                items: _residents
                    .map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text('${r.fullName} (Room ${r.room ?? '-'})'),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownStatus() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
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
                value: _status,
                isExpanded: true,
                onChanged: (v) => setState(() => _status = v!),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('active')),
                  DropdownMenuItem(
                      value: 'under_review', child: Text('under review')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('completed')),
                  DropdownMenuItem(value: 'archived', child: Text('archived')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownStaff() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Staff',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
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
              child: DropdownButton<int?>(
                value: _assignedStaffId,
                isExpanded: true,
                onChanged: (v) => setState(() => _assignedStaffId = v),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Unassigned')),
                  ..._staff.map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.fullName} (${s.role})'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}