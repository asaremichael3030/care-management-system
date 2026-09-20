import 'package:flutter/material.dart';
import '../../models/resident.dart';
import '../../services/medication_service.dart';
import '../../services/resident_service.dart';
import '../../theme.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _service = MedicationService();
  final _residentService = ResidentService();

  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _frequency = TextEditingController();
  final _route = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  final _instructions = TextEditingController();
  final _prescriber = TextEditingController();

  int? _residentId;
  bool _isActive = true;
  List<Resident> _residents = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _residentService.listResidents();
      if (!mounted) return;
      setState(() {
        _residents = list;
        _residentId = list.isNotEmpty ? list.first.id : null;
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
    _name.dispose();
    _dosage.dispose();
    _frequency.dispose();
    _route.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _instructions.dispose();
    _prescriber.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_residentId == null || _name.text.trim().isEmpty) {
      _show('Resident and medication name are required.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.create({
        'resident_id': _residentId,
        'name': _name.text.trim(),
        'dosage': _dosage.text.trim().isEmpty ? null : _dosage.text.trim(),
        'frequency':
            _frequency.text.trim().isEmpty ? null : _frequency.text.trim(),
        'route': _route.text.trim().isEmpty ? null : _route.text.trim(),
        'start_date':
            _startDate.text.trim().isEmpty ? null : _startDate.text.trim(),
        'end_date':
            _endDate.text.trim().isEmpty ? null : _endDate.text.trim(),
        'instructions': _instructions.text.trim().isEmpty
            ? null
            : _instructions.text.trim(),
        'prescriber':
            _prescriber.text.trim().isEmpty ? null : _prescriber.text.trim(),
        'is_active': _isActive,
      });
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
        title: const Text('Add Medication',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                _field('Medication Name', _name),
                _field('Dosage', _dosage),
              ]),
              _row([
                _field('Frequency', _frequency),
                _field('Route (Oral, Topical, etc.)', _route),
              ]),
              _row([
                _field('Start Date (YYYY-MM-DD)', _startDate),
                _field('End Date (YYYY-MM-DD)', _endDate),
              ]),
              _field('Prescriber', _prescriber),
              _field('Instructions', _instructions, lines: 3),
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v ?? true),
                    activeColor: AppColors.primary,
                  ),
                  const Text('Active medication',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
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
                            : const Text('Save Medication'),
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
          const Text('Resident',
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
              child: DropdownButton<int>(
                value: _residentId,
                isExpanded: true,
                onChanged: (v) => setState(() => _residentId = v),
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
}