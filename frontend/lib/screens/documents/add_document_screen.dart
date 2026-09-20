import 'package:flutter/material.dart';
import '../../models/document.dart';
import '../../models/resident.dart';
import '../../services/document_service.dart';
import '../../services/resident_service.dart';
import '../../theme.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key, this.existing, this.fixedResidentId});

  final ResidentDocument? existing;
  final int? fixedResidentId;

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _service = DocumentService();
  final _residentService = ResidentService();

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _fileUrl = TextEditingController();

  int? _residentId;
  String _type = 'Other';
  bool _visibleToFamily = true;
  List<Resident> _residents = [];
  bool _loading = true;
  bool _saving = false;

  static const List<String> _types = [
    'Agreement',
    'Medical',
    'Assessment',
    'Insurance',
    'Letter',
    'Photo',
    'Other',
  ];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _residentId = widget.fixedResidentId;
    _loadResidents();

    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _description.text = e.description ?? '';
      _fileUrl.text = e.fileUrl;
      _type = _types.contains(e.documentType) ? e.documentType : 'Other';
      _visibleToFamily = e.visibleToFamily;
      _residentId = e.residentId;
    }
  }

  Future<void> _loadResidents() async {
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
      setState(() => _loading = false);
      _show(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _fileUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_residentId == null ||
        _title.text.trim().isEmpty ||
        _fileUrl.text.trim().isEmpty) {
      _show('Resident, title, and file URL are required.');
      return;
    }
    setState(() => _saving = true);
    final payload = {
      'resident_id': _residentId,
      'title': _title.text.trim(),
      'document_type': _type,
      'description':
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      'file_url': _fileUrl.text.trim(),
      'visible_to_family': _visibleToFamily,
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
          _isEdit ? 'Edit Document' : 'Add Document',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.fixedResidentId == null) _dropdownResident(),
              _field('Title', _title),
              _dropdownType(),
              _field('File URL', _fileUrl,
                  hint: 'https://example.com/file.pdf'),
              _field('Description', _description, lines: 3),
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
                            : Text(_isEdit ? 'Update' : 'Save Document'),
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

  Widget _field(String label, TextEditingController c,
      {int lines = 1, String? hint}) {
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
              hintText: hint,
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

  Widget _dropdownType() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Document Type',
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
}