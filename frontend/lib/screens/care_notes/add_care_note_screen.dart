import 'package:flutter/material.dart';
import '../../models/resident.dart';
import '../../services/care_note_service.dart';
import '../../services/resident_service.dart';
import '../../theme.dart';

class AddCareNoteScreen extends StatefulWidget {
  const AddCareNoteScreen({super.key, this.fixedResidentId});
  final int? fixedResidentId;

  @override
  State<AddCareNoteScreen> createState() => _AddCareNoteScreenState();
}

class _AddCareNoteScreenState extends State<AddCareNoteScreen> {
  final _service = CareNoteService();
  final _residentService = ResidentService();

  final _content = TextEditingController();
  String _noteType = 'General';
  int? _residentId;
  bool _visibleToFamily = true;

  List<Resident> _residents = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  static const List<String> _noteTypes = [
    'General', 'Personal Care', 'Medication', 'Observation',
    'Activity', 'Meal', 'Mood', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _residentId = widget.fixedResidentId;
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _residentService.listResidents();
      if (!mounted) return;
      setState(() {
        _residents = list;
        _residentId ??= list.isNotEmpty ? list.first.id : null;
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
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_residentId == null || _content.text.trim().isEmpty) {
      setState(() => _error = 'Resident and content are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.create({
        'resident_id': _residentId,
        'note_type': _noteType,
        'content': _content.text.trim(),
        'visible_to_family': _visibleToFamily,
      });
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

    if (_residents.isEmpty && widget.fixedResidentId == null) {
      return _noResidentsScaffold('Add Care Note');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar('Add Care Note'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.fixedResidentId == null) _residentDropdown(),
              _noteTypeDropdown(),
              _field('Content', _content, lines: 5),
              Row(
                children: [
                  Checkbox(
                    value: _visibleToFamily,
                    onChanged: (v) =>
                        setState(() => _visibleToFamily = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                  const Text('Visible to family',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
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

  AppBar _buildAppBar(String title) => AppBar(
        title: Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
      );

  Widget _noResidentsScaffold(String title) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(title),
      body: const _NoResidentsMessage(),
    );
  }

  Widget _residentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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

  Widget _noteTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Note Type',
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
                value: _noteType,
                isExpanded: true,
                onChanged: (v) => setState(() => _noteType = v!),
                items: _noteTypes
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

  Widget _field(String label, TextEditingController c, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
                  : const Text('Save Note'),
            ),
          ),
        ),
      ],
    );
  }
}

// Shared widgets used by every Add screen.
class _NoResidentsMessage extends StatelessWidget {
  const _NoResidentsMessage();

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
              'Add a resident first, then you can create care records.',
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