import 'package:flutter/material.dart';
import '../../models/document.dart';
import '../../models/user.dart';
import '../../services/document_service.dart';
import '../../theme.dart';
import 'add_document_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({
    super.key,
    required this.currentUser,
    this.residentId,
  });

  final User currentUser;
  final int? residentId;

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _service = DocumentService();
  List<ResidentDocument> _docs = [];
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
          : await _service.listAll();
      if (!mounted) return;
      setState(() {
        _docs = list;
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

  Future<void> _addOrEdit([ResidentDocument? existing]) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddDocumentScreen(
          existing: existing,
          fixedResidentId: widget.residentId,
        ),
      ),
    );
    if (ok == true) _load();
  }

  Future<void> _delete(ResidentDocument d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('Delete "${d.title}"?'),
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
    if (ok != true) return;
    try {
      await _service.delete(d.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _openDocument(ResidentDocument d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(d.title,
            style: const TextStyle(decoration: TextDecoration.none)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Type: ${d.documentType}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
              if (d.residentName != null)
                Text(
                  'Resident: ${d.residentName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    decoration: TextDecoration.none,
                  ),
                ),
              const SizedBox(height: 12),
              if (d.description != null && d.description!.isNotEmpty)
                Text(
                  d.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
              const SizedBox(height: 12),
              SelectableText(
                d.fileUrl,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Copy the URL above and open it in a browser to view the file.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(decoration: TextDecoration.none),
            ),
          ),
        ],
      ),
    );
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

    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
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
                        'Documents',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Files and references for residents.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_canEdit)
                  ElevatedButton.icon(
                    onPressed: () => _addOrEdit(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Document'),
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
            if (_docs.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No documents yet.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              )
            else
              ..._docs.map(_buildCard),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(ResidentDocument d) {
    return GestureDetector(
      onTap: () => _openDocument(d),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      if (d.visibleToFamily)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Family visible',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      if (_canEdit) ...[
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () => _addOrEdit(d),
                          icon: const Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.primary),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _delete(d),
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: AppColors.danger),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${d.documentType}'
                    '${d.residentName != null ? ' . ${d.residentName}' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (d.description != null && d.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      d.description!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}