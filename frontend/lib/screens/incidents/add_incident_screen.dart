import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../models/resident.dart';
import '../../services/incident_service.dart';
import '../../services/resident_service.dart';
import '../../theme.dart';

class AddIncidentScreen extends StatefulWidget {
  const AddIncidentScreen({super.key, this.existing});

  final Incident? existing;

  @override
  State<AddIncidentScreen> createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  final _service = IncidentService();
  final _residentService = ResidentService();

  final _date = TextEditingController();
  final _time = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _people = TextEditingController();
  final _action = TextEditingController();

  String _type = 'Fall';
  String _status = 'open';
  int? _residentId;

  List<Resident> _residents = [];
  bool _loading = true;
  bool _saving = false;

  static const List<String> _types = [
    'Fall',
    'Accident',
    'Injury',
    'Missing item',
    'Medication error',
    'Behavioural',
    'Other',
  ];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _load();

    final e = widget.existing;
    if (e != null) {
      _date.text = e.occurredDate;
      _time.text = e.occurredTime ?? '';
      _location.text = e.location ?? '';
      _description.text = e.description;
      _people.text = e.peopleInvolved ?? '';
      _action.text = e.actionTaken ?? '';
      _type = _types.contains(e.incidentType) ? e.incidentType : 'Other';
      _status = e.status;
      _residentId = e.residentId;
    } else {
      final now = DateTime.now();
      _date.text = now.toIso8601String().split('T').first;
      _time.text =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _load() async {
    try {
      final r = await _residentService.listResidents();
      if (!mounted) return;
      setState(() {
        _residents = r;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _date.dispose();
    _time.dispose();
    _location.dispose();
    _description.dispose();
    _people.dispose();
    _action.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_description.text.trim().isEmpty) {
      _show('Description is required.');
      return;
    }
    if (_date.text.trim().isEmpty) {
      _show('Date is required.');
      return;
    }
    setState(() => _saving = true);
    final payload = {
      'resident_id': _residentId,
      'incident_type': _type,
      'occurred_date': _date.text.trim(),
      'occurred_time':
          _time.text.trim().isEmpty ? null : '${_time.text.trim()}:00',
      'location':
          _location.text.trim().isEmpty ? null : _location.text.trim(),
      'description': _description.text.trim(),
      'people_involved':
          _people.text.trim().isEmpty ? null : _people.text.trim(),
      'action_taken':
          _action.text.trim().isEmpty ? null : _action.text.trim(),
      'status': _status,
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
      _show(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
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
          _isEdit ? 'Edit Incident' : 'Report Incident',
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
                _dropdownType(),
                _dropdownStatus(),
              ]),
              _row([
                _field('Date (YYYY-MM-DD)', _date),
                _field('Time (HH:MM)', _time),
              ]),
              _field('Location', _location),
              _field('Description', _description, lines: 4),
              _field('People Involved', _people, lines: 2),
              _field('Action Taken', _action, lines: 3),
              const SizedBox(height: 20),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(_isEdit ? 'Update' : 'Submit Report'),
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

  Widget _dropdownResident() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resident (optional)',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
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
                value: _residentId,
                isExpanded: true,
                onChanged: (v) => setState(() => _residentId = v),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('None / Not resident related')),
                  ..._residents.map((r) => DropdownMenuItem(
                        value: r.id,
                        child: Text('${r.fullName} (Room ${r.room ?? '-'})'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownType() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Incident Type',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
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
                value: _type,
                isExpanded: true,
                onChanged: (v) => setState(() => _type = v!),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
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
          const Text('Status',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
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
                  DropdownMenuItem(value: 'open', child: Text('open')),
                  DropdownMenuItem(
                      value: 'under_review', child: Text('under review')),
                  DropdownMenuItem(value: 'resolved', child: Text('resolved')),
                  DropdownMenuItem(value: 'closed', child: Text('closed')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}