import 'package:flutter/material.dart';
import '../../models/resident.dart';
import '../../models/user.dart';
import '../../services/family_service.dart';
import '../../theme.dart';

class MyRelativeScreen extends StatefulWidget {
  const MyRelativeScreen({super.key, required this.currentUser});
  final User currentUser;

  @override
  State<MyRelativeScreen> createState() => _MyRelativeScreenState();
}

class _MyRelativeScreenState extends State<MyRelativeScreen> {
  final _service = FamilyService();
  Resident? _relative;
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
      final list = await _service.myRelative();
      if (!mounted) return;
      setState(() {
        _relative = list.isNotEmpty ? list.first : null;
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

    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Relative',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Profile of the resident you are linked to.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              _errorCard(_error!)
            else if (_relative == null)
              _infoCard('No relative is linked to your account yet.')
            else
              _buildProfile(_relative!),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(Resident r) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(
                  r.firstName.isNotEmpty
                      ? r.firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Room ${r.room ?? '-'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _statusPill(r.status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _field('Date of Birth', r.dateOfBirth),
          _field('Gender', r.gender),
          _field('Admission Date', r.admissionDate),
          const SizedBox(height: 16),
          const Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          _field('Name', r.emergencyContactName),
          _field('Phone', r.emergencyContactPhone),
          if (r.careNeeds != null && r.careNeeds!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Care Needs',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              r.careNeeds!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
          ],
          if (r.allergies != null && r.allergies!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Allergies',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              r.allergies!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.danger,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    final color = status == 'active' ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _infoCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          msg,
          style: const TextStyle(
            color: AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline,
              size: 42, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }
}