import 'package:flutter/material.dart';
import '../../services/resident_service.dart';
import '../../theme.dart';

// Full-page form to add a new resident.
class AddResidentScreen extends StatefulWidget {
  const AddResidentScreen({super.key});

  @override
  State<AddResidentScreen> createState() => _AddResidentScreenState();
}

class _AddResidentScreenState extends State<AddResidentScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _dateOfBirth = TextEditingController();
  final _room = TextEditingController();
  final _admissionDate = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  final _careNeeds = TextEditingController();
  final _allergies = TextEditingController();
  final _notes = TextEditingController();

  String _gender = 'Female';
  String _status = 'active';
  bool _saving = false;

  final ResidentService _service = ResidentService();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _dateOfBirth.dispose();
    _room.dispose();
    _admissionDate.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    _careNeeds.dispose();
    _allergies.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
      _showMessage('First name and last name are required.');
      return;
    }

    setState(() => _saving = true);

    try {
      await _service.createResident({
        'first_name': _firstName.text.trim(),
        'last_name': _lastName.text.trim(),
        'date_of_birth': _dateOfBirth.text.trim().isEmpty
            ? null
            : _dateOfBirth.text.trim(),
        'gender': _gender,
        'room': _room.text.trim().isEmpty ? null : _room.text.trim(),
        'admission_date': _admissionDate.text.trim().isEmpty
            ? null
            : _admissionDate.text.trim(),
        'status': _status,
        'emergency_contact_name': _emergencyName.text.trim().isEmpty
            ? null
            : _emergencyName.text.trim(),
        'emergency_contact_phone': _emergencyPhone.text.trim().isEmpty
            ? null
            : _emergencyPhone.text.trim(),
        'care_needs': _careNeeds.text.trim().isEmpty
            ? null
            : _careNeeds.text.trim(),
        'allergies':
            _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
        'important_notes': _notes.text.trim().isEmpty
            ? null
            : _notes.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      _showMessage(message);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Resident',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Personal Information'),
              _row([
                _field('First Name', _firstName),
                _field('Last Name', _lastName),
              ]),
              _row([
                _field('Date of Birth (YYYY-MM-DD)', _dateOfBirth),
                _dropdown('Gender', _gender, const [
                  'Female',
                  'Male',
                  'Other',
                  'Prefer not to say',
                ], (v) => setState(() => _gender = v!)),
              ]),
              _row([
                _field('Room', _room),
                _field('Admission Date (YYYY-MM-DD)', _admissionDate),
              ]),
              _row([
                _dropdown('Status', _status, const [
                  'active',
                  'on_leave',
                  'discharged',
                  'deceased',
                ], (v) => setState(() => _status = v!)),
              ]),

              const SizedBox(height: 16),
              _sectionTitle('Emergency Contact'),
              _row([
                _field('Contact Name', _emergencyName),
                _field('Contact Phone', _emergencyPhone),
              ]),

              const SizedBox(height: 16),
              _sectionTitle('Care Information'),
              _field('Care Needs', _careNeeds, lines: 3),
              _field('Allergies', _allergies, lines: 2),
              _field('Important Notes', _notes, lines: 3),

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
                            : const Text('Save Resident'),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
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

  Widget _field(String label, TextEditingController controller,
      {int lines = 1}) {
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
            controller: controller,
            maxLines: lines,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
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

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                onChanged: onChanged,
                items: options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}