import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _service = ReportService();
  ReportSummary? _summary;
  bool _loading = true;
  String? _error;

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
      final s = await _service.summary();
      if (!mounted) return;
      setState(() {
        _summary = s;
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

    final s = _summary!;

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
                        'Reports',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Summary of system activity.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Top-line numbers.
            LayoutBuilder(
              builder: (context, constraints) {
                final int cols = constraints.maxWidth >= 900 ? 4 : 2;
                const double spacing = 12;
                final double w =
                    (constraints.maxWidth - spacing * (cols - 1)) / cols;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    _StatCard(
                      width: w,
                      icon: Icons.elderly_outlined,
                      value: '${s.residentsTotal}',
                      label: 'Residents',
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      width: w,
                      icon: Icons.medication_outlined,
                      value: '${s.medicationsActive}',
                      label: 'Active Medications',
                      color: AppColors.accent,
                    ),
                    _StatCard(
                      width: w,
                      icon: Icons.warning_amber_outlined,
                      value: '${s.incidentsThisMonth}',
                      label: 'Incidents this month',
                      color: AppColors.danger,
                    ),
                    _StatCard(
                      width: w,
                      icon: Icons.assignment_outlined,
                      value: '${s.carePlansDueForReview}',
                      label: 'Care Plans due',
                      color: AppColors.warning,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Resident report.
            _SectionCard(
              title: 'Resident Report',
              child: Column(
                children: [
                  _StatLine('Total residents', '${s.residentsTotal}'),
                  ...s.residentsByStatus.map(
                    (i) => _StatLine(
                      _humanize(i.label),
                      '${i.count}',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Medication report.
            _SectionCard(
              title: 'Medication Report',
              child: Column(
                children: [
                  _StatLine('Total medications', '${s.medicationsTotal}'),
                  _StatLine('Active medications', '${s.medicationsActive}'),
                  _StatLine(
                    'Records this month',
                    '${s.medicationRecordsThisMonth}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Incident report.
            _SectionCard(
              title: 'Incident Report',
              child: Column(
                children: [
                  _StatLine('Total incidents', '${s.incidentsTotal}'),
                  _StatLine('This month', '${s.incidentsThisMonth}'),
                  const SizedBox(height: 8),
                  const _SubHeading('By status'),
                  ...s.incidentsByStatus.map(
                    (i) => _StatLine(_humanize(i.label), '${i.count}'),
                  ),
                  if (s.incidentsByType.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const _SubHeading('Top types'),
                    ...s.incidentsByType.map(
                      (i) => _StatLine(i.label, '${i.count}'),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Care task report.
            _SectionCard(
              title: 'Care Task Report',
              child: Column(
                children: [
                  _StatLine('Total tasks', '${s.careTasksTotal}'),
                  _StatLine('Completed', '${s.careTasksCompleted}'),
                  if (s.careTasksTotal > 0)
                    _StatLine(
                      'Completion rate',
                      '${((s.careTasksCompleted / s.careTasksTotal) * 100).toStringAsFixed(1)}%',
                    ),
                  const SizedBox(height: 8),
                  const _SubHeading('By status'),
                  ...s.careTasksByStatus.map(
                    (i) => _StatLine(_humanize(i.label), '${i.count}'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Staff and shift report.
            _SectionCard(
              title: 'Staff and Shift Report',
              child: Column(
                children: [
                  _StatLine('Total staff', '${s.staffTotal}'),
                  _StatLine('Shifts this week', '${s.shiftsThisWeek}'),
                  const SizedBox(height: 8),
                  const _SubHeading('Staff by role'),
                  ...s.staffByRole.map(
                    (i) => _StatLine(i.label, '${i.count}'),
                  ),
                  if (s.staffByStatus.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const _SubHeading('Staff by status'),
                    ...s.staffByStatus.map(
                      (i) => _StatLine(_humanize(i.label), '${i.count}'),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Care plan review report.
            _SectionCard(
              title: 'Care Plan Review Report',
              child: Column(
                children: [
                  _StatLine('Total care plans', '${s.carePlansTotal}'),
                  _StatLine(
                    'Due for review (next 30 days)',
                    '${s.carePlansDueForReview}',
                  ),
                  _StatLine('Overdue reviews', '${s.carePlansOverdue}'),
                  const SizedBox(height: 8),
                  const _SubHeading('By status'),
                  ...s.carePlansByStatus.map(
                    (i) => _StatLine(_humanize(i.label), '${i.count}'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Family and messages.
            _SectionCard(
              title: 'Family and Messages',
              child: Column(
                children: [
                  _StatLine(
                    'Family members linked',
                    '${s.familiesLinked}',
                  ),
                  _StatLine('Total messages', '${s.messagesTotal}'),
                  _StatLine('Messages this week', '${s.messagesThisWeek}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _humanize(String label) {
    if (label.isEmpty) return label;
    final spaced = label.replaceAll('_', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  const _SubHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}