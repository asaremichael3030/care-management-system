import 'package:flutter/material.dart';
import '../../theme.dart';

class RolesPermissionsScreen extends StatelessWidget {
  const RolesPermissionsScreen({super.key});

  // Capability matrix. Keep it in sync with the backend rules.
  static const List<String> _features = [
    'View dashboard',
    'View residents',
    'Create residents',
    'Edit residents',
    'Delete residents',
    'Manage users',
    'Manage staff',
    'Manage care plans',
    'Record medication',
    'View audit logs',
    'View reports',
    'Manage shifts',
    'Send messages',
    'View linked relative only',
  ];

  // For each feature, which roles have it.
  // Order: Administrator, Manager / Senior Carer, Care Worker, Family Member.
  static const List<List<bool>> _permissions = [
    [true, true, true, true], // View dashboard
    [true, true, true, false], // View residents
    [true, true, false, false], // Create residents
    [true, true, false, false], // Edit residents
    [true, false, false, false], // Delete residents
    [true, false, false, false], // Manage users
    [true, true, false, false], // Manage staff
    [true, true, false, false], // Manage care plans
    [true, true, true, false], // Record medication
    [true, false, false, false], // View audit logs
    [true, true, false, false], // View reports
    [true, true, false, false], // Manage shifts
    [true, true, true, true], // Send messages
    [false, false, false, true], // View linked relative only
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Roles & Permissions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'What each role can do in the system.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 20),

            // Role summary cards.
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _RoleCard(
                  title: 'Administrator',
                  color: AppColors.primary,
                  icon: Icons.admin_panel_settings_outlined,
                  description:
                      'Full access to every part of the system including user management and audit logs.',
                ),
                _RoleCard(
                  title: 'Manager / Senior Carer',
                  color: AppColors.accent,
                  icon: Icons.supervisor_account_outlined,
                  description:
                      'Manages residents, care plans, medication, shifts, and staff. No system administration.',
                ),
                _RoleCard(
                  title: 'Care Worker',
                  color: AppColors.warning,
                  icon: Icons.volunteer_activism_outlined,
                  description:
                      'Provides daily care, records tasks and notes, and administers medication.',
                ),
                _RoleCard(
                  title: 'Family Member',
                  color: AppColors.success,
                  icon: Icons.family_restroom_outlined,
                  description:
                      'Reads information about their own linked relative only, and can message the care home.',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Permissions matrix.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Header row.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: const [
                        Expanded(flex: 4, child: _HeaderCell('Feature')),
                        Expanded(
                            flex: 2,
                            child: _HeaderCell('Admin', center: true)),
                        Expanded(
                            flex: 2,
                            child: _HeaderCell('Manager', center: true)),
                        Expanded(
                            flex: 2,
                            child: _HeaderCell('Care Worker', center: true)),
                        Expanded(
                            flex: 2,
                            child: _HeaderCell('Family', center: true)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ..._features.asMap().entries.map((entry) {
                    final i = entry.key;
                    final row = _permissions[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textDark,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _PermissionCell(allowed: row[0]),
                          ),
                          Expanded(
                            flex: 2,
                            child: _PermissionCell(allowed: row[1]),
                          ),
                          Expanded(
                            flex: 2,
                            child: _PermissionCell(allowed: row[2]),
                          ),
                          Expanded(
                            flex: 2,
                            child: _PermissionCell(allowed: row[3]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The backend enforces every rule in this table. Hiding a button in the app is not enough on its own.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.description,
  });

  final String title;
  final Color color;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textMuted,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.center = false});
  final String label;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        decoration: TextDecoration.none,
      ),
    );
  }
}

class _PermissionCell extends StatelessWidget {
  const _PermissionCell({required this.allowed});
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Icon(
        allowed ? Icons.check_circle : Icons.remove_circle_outline,
        size: 16,
        color: allowed ? AppColors.success : AppColors.textMuted,
      ),
    );
  }
}