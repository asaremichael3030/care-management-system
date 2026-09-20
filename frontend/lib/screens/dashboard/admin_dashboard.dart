import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../theme.dart';
import '../audit_logs/audit_logs_screen.dart';
import '../care_plans/care_plans_screen.dart';
import '../documents/documents_screen.dart';
import '../family/family_links_screen.dart';
import '../incidents/incidents_screen.dart';
import '../medications/medications_screen.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';
import '../reports/reports_screen.dart';
import '../residents/residents_screen.dart';
import '../risk_assessments/risk_assessments_screen.dart';
import '../shifts/shifts_screen.dart';
import '../staff/staff_screen.dart';
import 'dashboard_layout.dart';
import '../users/users_screen.dart';
import '../settings/settings_screen.dart';
import '../roles/roles_permissions_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final User user;
  final VoidCallback onLogout;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const List<DashboardNavItem> _navItems = [
    DashboardNavItem('Dashboard', Icons.dashboard_outlined),
    DashboardNavItem('Users', Icons.people_outline),
    DashboardNavItem('Staff', Icons.badge_outlined),
    DashboardNavItem('Residents', Icons.elderly_outlined),
    DashboardNavItem('Family Links', Icons.link_outlined),
    DashboardNavItem('Roles & Permissions', Icons.lock_outline),
    DashboardNavItem('Care Plans', Icons.assignment_outlined),
    DashboardNavItem('Medication', Icons.medication_outlined),
    DashboardNavItem('Shifts & Rota', Icons.calendar_today_outlined),
    DashboardNavItem('Incidents', Icons.warning_amber_outlined),
    DashboardNavItem('Reports', Icons.bar_chart_outlined),
    DashboardNavItem('Audit Logs', Icons.receipt_long_outlined),
    DashboardNavItem('Notifications', Icons.notifications_none),
    DashboardNavItem('Messages', Icons.chat_bubble_outline),
    DashboardNavItem('Documents', Icons.folder_outlined),
    DashboardNavItem('Settings', Icons.settings_outlined),
  ];

  String _active = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      user: widget.user,
      navItems: _navItems,
      activeItem: _active,
      onSelect: (item) => setState(() => _active = item),
      onLogout: widget.onLogout,
      child: _buildActivePage(),
    );
  }

  Widget _buildActivePage() {
    switch (_active) {
      case 'Dashboard':
        return _buildDashboardContent();
      case 'Residents':
        return ResidentsScreen(currentUser: widget.user);
      case 'Family Links':
        return const FamilyLinksScreen();
      case 'Care Plans':
        return CarePlansScreen(currentUser: widget.user);
      case 'Medication':
        return MedicationsScreen(currentUser: widget.user);
      case 'Risk Assessments':
        return RiskAssessmentsScreen(currentUser: widget.user);
      case 'Incidents':
        return IncidentsScreen(currentUser: widget.user);
      case 'Staff':
        return StaffScreen(currentUser: widget.user);
      case 'Shifts & Rota':
        return ShiftsScreen(currentUser: widget.user, mode: 'all');
      case 'Messages':
        return MessagesScreen(currentUser: widget.user);
      case 'Notifications':
        return NotificationsScreen(currentUser: widget.user);
      case 'Documents':
        return DocumentsScreen(currentUser: widget.user);
      case 'Reports':
        return const ReportsScreen();
      case 'Audit Logs':
        return const AuditLogsScreen();
      case 'Users':
        return UsersScreen(currentUser: widget.user);
        case 'Settings':
  return SettingsScreen(currentUser: widget.user);
  case 'Roles & Permissions':
  return const RolesPermissionsScreen();
      default:
        return DashboardPlaceholder(title: _active);
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.user.firstName}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'System overview and key information.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final int columns = constraints.maxWidth >= 900 ? 4 : 2;
              final double spacing = 12;
              final double cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.elderly_outlined,
                    value: '42',
                    label: 'Total Residents',
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.people_outline,
                    value: '18',
                    label: 'Active Care Workers',
                    color: AppColors.accent,
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.checklist_outlined,
                    value: '32',
                    label: "Today's Care Tasks",
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.badge_outlined,
                    value: '12',
                    label: 'Staff On Duty',
                    color: AppColors.success,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildResidentOverview()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStaffOverview()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildResidentOverview(),
                  const SizedBox(height: 16),
                  _buildStaffOverview(),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRecentActivities()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRecentResidents()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildRecentActivities(),
                  const SizedBox(height: 16),
                  _buildRecentResidents(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResidentOverview() {
    const int total = 42;
    const int active = 35;
    const int newAdmissions = 3;
    const int reviewDue = 2;
    const int onLeave = 2;

    return _SectionCard(
      title: 'Resident Overview',
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _DonutPainter(
                    segments: [
                      _DonutSegment(active / total, AppColors.primary),
                      _DonutSegment(newAdmissions / total, AppColors.accent),
                      _DonutSegment(reviewDue / total, AppColors.warning),
                      _DonutSegment(onLeave / total, AppColors.textMuted),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      'Total Residents',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _LegendRow(
                  color: AppColors.primary,
                  label: 'Active',
                  value: '$active',
                ),
                _LegendRow(
                  color: AppColors.accent,
                  label: 'New Admissions',
                  value: '$newAdmissions',
                ),
                _LegendRow(
                  color: AppColors.warning,
                  label: 'Review Due',
                  value: '$reviewDue',
                ),
                _LegendRow(
                  color: AppColors.textMuted,
                  label: 'On Leave',
                  value: '$onLeave',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffOverview() {
    return _SectionCard(
      title: 'Staff Overview',
      trailing: TextButton(
        onPressed: () {
          setState(() => _active = 'Staff');
        },
        child: const Text(
          'View Staff',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: const [
          _StaffStatusRow(
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            value: '12',
            label: 'On Duty',
          ),
          SizedBox(height: 12),
          _StaffStatusRow(
            icon: Icons.cancel_outlined,
            color: AppColors.textMuted,
            value: '6',
            label: 'Off Duty',
          ),
          SizedBox(height: 12),
          _StaffStatusRow(
            icon: Icons.beach_access_outlined,
            color: AppColors.warning,
            value: '0',
            label: 'On Leave',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    const activities = [
      ('New resident added: John Wilson', '11:30 AM', Icons.person_add_alt),
      ('Care plan updated: Mrs. Green', '10:45 AM', Icons.assignment_outlined),
      (
        'Medication record completed: Mr. Brown',
        '10:30 AM',
        Icons.medication_outlined
      ),
      ('Incident reported: Room 15', '09:50 AM', Icons.warning_amber_outlined),
      (
        'Family account created: Emily Carter',
        '08:15 AM',
        Icons.family_restroom_outlined
      ),
    ];

    return _SectionCard(
      title: 'Recent Activities',
      trailing: TextButton(
        onPressed: () {
          setState(() => _active = 'Audit Logs');
        },
        child: const Text(
          'View All',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: activities.map((a) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(a.$3, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.$1,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.$2,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentResidents() {
    const residents = [
      ('Mary Smith', '12', 'Active', AppColors.success),
      ('John Brown', '15', 'Active', AppColors.success),
      ('David Williams', '21', 'Review', AppColors.warning),
      ('Patricia Green', '08', 'Active', AppColors.success),
      ('Margaret Wilson', '17', 'Active', AppColors.success),
    ];

    return _SectionCard(
      title: 'Recent Residents',
      trailing: TextButton(
        onPressed: () {
          setState(() => _active = 'Residents');
        },
        child: const Text(
          'View All',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Room',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...residents.map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      r.$1,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.$2,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: r.$4.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r.$3,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: r.$4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Simple card used for all sections on the dashboard.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// One stat card at the top of the dashboard.
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// One row in the resident overview legend.
class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// One row in the staff overview panel.
class _StaffStatusRow extends StatelessWidget {
  const _StaffStatusRow({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// A single arc segment on the donut chart.
class _DonutSegment {
  const _DonutSegment(this.fraction, this.color);
  final double fraction;
  final Color color;
}

// Draws the resident overview donut chart.
class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments});
  final List<_DonutSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 14;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final double sweep = segment.fraction * 2 * math.pi;
      final paint = Paint()
        ..color = segment.color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    if (oldDelegate.segments.length != segments.length) return true;
    for (int i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].fraction != segments[i].fraction ||
          oldDelegate.segments[i].color != segments[i].color) {
        return true;
      }
    }
    return false;
  }
}